"""Install verified upstream releases; atomically switch only complete downloads."""

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
import urllib.request


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


def download(asset, destination):
    digest = hashlib.sha256()
    with request(asset["browser_download_url"]) as response, destination.open("wb") as output:
        while chunk := response.read(1024 * 1024):
            digest.update(chunk)
            output.write(chunk)
    if "sha256:" + digest.hexdigest() != asset["digest"]:
        raise ValueError("Release checksum mismatch")


def install(tool, base):
    tag, asset = release(tool)
    root = base / tool
    root.mkdir(parents=True, exist_ok=True)
    version = root / tag
    current = root / "current"
    if current.is_symlink() and current.resolve() == version:
        return
    if not version.exists():
        with tempfile.TemporaryDirectory(prefix=".download-", dir=root) as temporary:
            stage = Path(temporary)
            archive = stage / "download"
            download(asset, archive)
            package = stage / "package"
            package.mkdir()
            if tool == "codex":
                with tarfile.open(archive) as tar:
                    tar.extractall(package, filter="data")
                subprocess.run([package / "bin/codex", "--version"], check=True, timeout=15)
            else:
                archive.rename(package / "T3.AppImage")
                (package / "T3.AppImage").chmod(0o755)
                (package / ".digest").write_text(asset["digest"].removeprefix("sha256:"))
            package.rename(version)
    pending = root / ".current-new"
    pending.unlink(missing_ok=True)
    pending.symlink_to(tag)
    pending.replace(current)
    print(f"Installed {tool} {tag}", flush=True)
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
    base = Path(os.environ.get("XDG_DATA_HOME", str(Path.home() / ".local/share"))) / "agent-tools"
    base.mkdir(parents=True, exist_ok=True)
    tools = sys.argv[1:] or ["codex", "t3code"]
    if any(tool not in ("codex", "t3code") for tool in tools):
        raise SystemExit("Usage: agent-tools-update [codex|t3code]")
    failed = False
    with (base / ".update.lock").open("w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        for tool in tools:
            try:
                install(tool, base)
            except Exception as error:
                print(f"{tool} update failed: {error}", file=sys.stderr)
                failed = True
    return int(failed)


if __name__ == "__main__":
    sys.exit(main())
