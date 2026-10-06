"""Install verified upstream releases; atomically switch only complete downloads."""

import argparse
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tarfile
import tempfile
import time
import urllib.request


LABELS = {"codex": "Codex CLI", "t3code": "T3 Code Nightly"}


class Status:
    """Keep CLI, desktop and on-demand status in sync without requiring a GUI."""

    def __init__(self, base, notify=False):
        self.path = base / "status.json"
        self.notify = notify
        self.notification_id = "0"

    def report(self, message, phase, tool=None, percent=None, transient=False):
        print(message, file=sys.stderr, flush=True)
        if not transient:
            pending = self.path.with_name(f".status-{os.getpid()}")
            pending.write_text(json.dumps({
                "message": message, "phase": phase, "tool": tool,
                "percent": percent, "updated_at": time.time(), "pid": os.getpid(),
            }) + "\n")
            pending.replace(self.path)
        if self.notify:
            command = [
                "notify-send", "--app-name=T3 Code", "--icon=t3code-nightly",
                "--print-id", f"--replace-id={self.notification_id}",
                "--expire-time=8000" if phase in ("ready", "failed") else "--expire-time=0",
            ]
            if percent is not None:
                command.append(f"--hint=int:value:{percent}")
            command.extend(["T3 Code", message])
            try:
                result = subprocess.run(command, capture_output=True, text=True, timeout=2)
                if result.returncode == 0 and result.stdout.strip().isdigit():
                    self.notification_id = result.stdout.strip()
                else:
                    self.notify = False
            except (OSError, subprocess.TimeoutExpired):
                self.notify = False


def installed(tool, base):
    executable = "bin/codex" if tool == "codex" else "T3.AppImage"
    return os.access(base / tool / "current" / executable, os.X_OK)


def request(url):
    return urllib.request.urlopen(
        urllib.request.Request(url, headers={"User-Agent": "nixos-agent-tools"}),
        timeout=30,
    )


def release(tool):
    repo = "openai/codex" if tool == "codex" else "pingdotgg/t3code"
    endpoint = "/latest" if tool == "codex" else "?per_page=100"
    with request(f"https://api.github.com/repos/{repo}/releases{endpoint}") as response:
        data = json.load(response)
    if tool == "t3code":
        candidates = [r for r in data if not r["draft"] and "-nightly." in r["tag_name"]]
        data = max(candidates, key=lambda r: r["published_at"])
    tag = data["tag_name"]
    if not re.fullmatch(r"[A-Za-z0-9._-]+", tag):
        raise ValueError("Invalid release tag")
    name = "codex-package-x86_64-unknown-linux-musl.tar.gz"
    if tool == "t3code":
        name = f"T3-Code-{tag.removeprefix('v')}-x86_64.AppImage"
    asset = next(a for a in data["assets"] if a["name"] == name)
    if not re.fullmatch(r"sha256:[0-9a-f]{64}", asset.get("digest") or ""):
        raise ValueError(f"Missing SHA-256 digest for {name}")
    return tag, asset


def download(asset, destination, status, tool):
    digest = hashlib.sha256()
    started = time.monotonic()
    last_report = 0
    received = 0
    total = asset["size"]
    with request(asset["browser_download_url"]) as response, destination.open("wb") as output:
        while chunk := response.read(1024 * 1024):
            digest.update(chunk)
            output.write(chunk)
            received += len(chunk)
            now = time.monotonic()
            if now - last_report >= 1 or received == total:
                speed = received / max(now - started, 0.001)
                percent = min(100, received * 100 // total) if total else None
                progress = f"{received / 2**20:.1f}"
                if total:
                    progress += f" / {total / 2**20:.1f}"
                percentage = f"{percent}% — " if percent is not None else ""
                message = f"Downloading {LABELS[tool]}: {percentage}{progress} MiB ({speed / 2**20:.1f} MiB/s)"
                if total and speed:
                    message += f", about {max(0, total - received) / speed:.0f}s remaining"
                status.report(message, "downloading", tool, percent)
                last_report = now
    status.report(f"Verifying {LABELS[tool]} download…", "verifying", tool)
    if "sha256:" + digest.hexdigest() != asset["digest"]:
        raise ValueError("Release checksum mismatch")


def install(tool, base, status, max_age=0):
    root = base / tool
    checked = root / ".last-check"
    if installed(tool, base) and checked.exists() and 0 <= time.time() - checked.stat().st_mtime < max_age:
        status.report(f"{LABELS[tool]}: {os.readlink(root / 'current')} (recently checked)", "checked", tool)
        return
    status.report(f"Checking for the latest {LABELS[tool]} release…", "checking", tool)
    tag, asset = release(tool)
    root.mkdir(parents=True, exist_ok=True)
    version = root / tag
    current = root / "current"
    if installed(tool, base) and current.is_symlink() and current.resolve() == version:
        checked.touch()
        status.report(f"{LABELS[tool]} {tag} is up to date.", "checked", tool)
        return
    if not version.exists():
        with tempfile.TemporaryDirectory(prefix=".download-", dir=root) as temporary:
            stage = Path(temporary)
            archive = stage / "download"
            status.report(f"Downloading {LABELS[tool]} {tag}…", "downloading", tool, 0)
            download(asset, archive, status, tool)
            package = stage / "package"
            package.mkdir()
            if tool == "codex":
                status.report(f"Unpacking and checking Codex CLI {tag}…", "installing", tool)
                with tarfile.open(archive) as tar:
                    tar.extractall(package, filter="data")
                result = subprocess.run(
                    [package / "bin/codex", "--version"], check=True,
                    capture_output=True, text=True, timeout=15,
                )
                if result.stdout.strip() != f"codex-cli {tag.removeprefix('rust-v')}":
                    raise ValueError(f"Codex version does not match {tag}: {result.stdout.strip()}")
            else:
                archive.rename(package / "T3.AppImage")
                (package / "T3.AppImage").chmod(0o755)
                (package / ".digest").write_text(asset["digest"].removeprefix("sha256:"))
            package.rename(version)
    pending = root / ".current-new"
    pending.unlink(missing_ok=True)
    pending.symlink_to(tag)
    pending.replace(current)
    checked.touch()
    status.report(f"Installed {LABELS[tool]} {tag}.", "installed", tool)
    prune(root, version)


def prune(root, current):
    """Keep current and previous versions, plus anything used by a running app."""
    references = []
    for process in Path("/proc").glob("[0-9]*"):
        try:
            if process.stat().st_uid != os.getuid():
                continue
            references.append((process / "cmdline").read_bytes())
            references.append((process / "maps").read_bytes())
        except FileNotFoundError:
            pass
        except PermissionError:
            return  # Cannot establish which versions are still in use.
    versions = sorted(
        (p for p in root.iterdir() if p.is_dir() and not p.is_symlink() and not p.name.startswith(".")),
        key=lambda p: p.stat().st_mtime, reverse=True,
    )
    cache = Path(os.environ.get("XDG_CACHE_HOME", str(Path.home() / ".cache"))) / "appimage-run"
    for directory in versions[2:]:
        if directory == current:
            continue
        digest_file = directory / ".digest"
        digest = digest_file.read_text() if digest_file.exists() else None
        targets = [str(directory).encode()]
        if digest:
            targets.append(str(cache / digest).encode())
        if any(target in reference for target in targets for reference in references):
            continue
        shutil.rmtree(directory)
        if digest and re.fullmatch(r"[0-9a-f]{64}", digest):
            shutil.rmtree(cache / digest, ignore_errors=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("tools", nargs="*", choices=["codex", "t3code"])
    parser.add_argument("--notify", action="store_true", help="Show desktop progress notifications")
    parser.add_argument("--max-age", type=int, default=0, help="Reuse successful checks younger than this many seconds")
    parser.add_argument("--status", action="store_true", help="Show the last update status and installed versions")
    args = parser.parse_args()
    base = Path(os.environ.get("XDG_DATA_HOME", str(Path.home() / ".local/share"))) / "agent-tools"
    if args.status:
        status_file = base / "status.json"
        if status_file.exists():
            print(status_file.read_text().strip())
        for tool in LABELS:
            current = base / tool / "current"
            print(f"{LABELS[tool]}: {os.readlink(current) if installed(tool, base) else 'not installed'}")
        return 0
    base.mkdir(parents=True, exist_ok=True)
    tools = args.tools or ["codex", "t3code"]
    status = Status(base, args.notify)
    errors = []
    with (base / ".update.lock").open("a") as lock:
        waiting = False
        while True:
            try:
                fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
                break
            except BlockingIOError:
                if not waiting:
                    status.report("Waiting for the update already in progress…", "waiting", transient=True)
                    waiting = True
                time.sleep(0.25)
        for tool in dict.fromkeys(tools):
            try:
                install(tool, base, status, args.max_age)
            except Exception as error:
                fallback = "using the installed version" if installed(tool, base) else "no installed version available"
                message = f"{LABELS[tool]} update failed: {error}; {fallback}."
                errors.append(message)
                status.report(message, "failed", tool)
        status.report("\n".join(errors) if errors else "Agent tools are ready.", "failed" if errors else "ready")
    return int(bool(errors))


if __name__ == "__main__":
    sys.exit(main())
