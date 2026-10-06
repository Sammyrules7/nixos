"""Regression checks for download integrity, atomic installation and launch caching."""

import contextlib
import fcntl
import hashlib
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tarfile
import tempfile
import unittest
from unittest.mock import patch


SCRIPT = Path(__file__).with_name("update.py")
spec = importlib.util.spec_from_file_location("updater", SCRIPT)
updater = importlib.util.module_from_spec(spec)
spec.loader.exec_module(updater)


class UpdaterTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.base = Path(self.temporary.name)
        self.status = updater.Status(self.base)
        self.output = contextlib.redirect_stderr(io.StringIO())
        self.output.__enter__()

    def tearDown(self):
        self.output.__exit__(None, None, None)
        self.temporary.cleanup()

    def asset(self, content=b"appimage", digest=None):
        source = self.base / "asset"
        source.write_bytes(content)
        return {
            "browser_download_url": source.as_uri(),
            "size": len(content),
            "digest": digest or "sha256:" + hashlib.sha256(content).hexdigest(),
        }

    def old_install(self, tool):
        root = self.base / tool
        old = root / "old"
        relative = "bin/codex" if tool == "codex" else "T3.AppImage"
        binary = old / relative
        binary.parent.mkdir(parents=True)
        binary.write_text("old version")
        binary.chmod(0o755)
        (root / "current").symlink_to("old")
        return root

    def codex_asset(self, reported_version="0.160.1"):
        data = io.BytesIO()
        with tarfile.open(fileobj=data, mode="w:gz") as archive:
            files = {
                "bin/codex": f"#!/bin/sh\necho 'codex-cli {reported_version}'\n".encode(),
                "bin/codex-code-mode-host": b"helper",
                "codex-package.json": b"{}",
            }
            for name, content in files.items():
                info = tarfile.TarInfo(name)
                info.size = len(content)
                info.mode = 0o755 if name.startswith("bin/") else 0o644
                archive.addfile(info, io.BytesIO(content))
        return self.asset(data.getvalue())

    def test_checksum_failure_preserves_previous_installation(self):
        root = self.old_install("t3code")
        asset = self.asset(digest="sha256:" + "0" * 64)
        with patch.object(updater, "release", return_value=("new", asset)):
            with self.assertRaisesRegex(ValueError, "checksum"):
                updater.install("t3code", self.base, self.status)
        self.assertEqual(os.readlink(root / "current"), "old")
        self.assertFalse((root / "new").exists())
        self.assertFalse((root / ".last-check").exists())
        self.assertFalse(list(root.glob(".download-*")))

    def test_complete_codex_package_and_matching_version_installed(self):
        root = self.old_install("codex")
        asset = self.codex_asset()
        with patch.object(updater, "release", return_value=("rust-v0.160.1", asset)):
            with patch.object(updater, "prune"):
                updater.install("codex", self.base, self.status)
        self.assertEqual(os.readlink(root / "current"), "rust-v0.160.1")
        self.assertTrue((root / "current/bin/codex-code-mode-host").exists())
        self.assertTrue((root / "current/codex-package.json").exists())
        self.assertTrue((root / "old/bin/codex").exists())

    def test_wrong_codex_version_preserves_previous_installation(self):
        root = self.old_install("codex")
        asset = self.codex_asset("0.159.0")
        with patch.object(updater, "release", return_value=("rust-v0.160.1", asset)):
            with self.assertRaisesRegex(ValueError, "version does not match"):
                updater.install("codex", self.base, self.status)
        self.assertEqual(os.readlink(root / "current"), "old")
        self.assertFalse((root / "rust-v0.160.1").exists())

    def test_recent_check_skips_network_but_manual_check_refreshes(self):
        root = self.old_install("codex")
        (root / ".last-check").touch()
        with patch.object(updater, "release") as release:
            updater.install("codex", self.base, self.status, max_age=300)
            release.assert_not_called()
        with patch.object(updater, "release", return_value=("old", {})) as release:
            updater.install("codex", self.base, self.status)
            release.assert_called_once_with("codex")

    def test_missing_binary_cannot_use_recent_check(self):
        root = self.base / "codex"
        root.mkdir()
        (root / ".last-check").touch()
        with patch.object(updater, "release", side_effect=OSError("offline")) as release:
            with self.assertRaises(OSError):
                updater.install("codex", self.base, self.status, max_age=300)
            release.assert_called_once()

    def test_download_records_full_progress(self):
        asset = self.asset(b"x" * (2 * 1024 * 1024))
        updater.download(asset, self.base / "download", self.status, "t3code")
        recorded = json.loads(self.status.path.read_text())
        self.assertEqual(recorded["phase"], "verifying")
        self.assertEqual((self.base / "download").stat().st_size, asset["size"])

    def test_notification_replaced_with_percentage_and_expiry(self):
        self.status.notify = True
        with patch.object(updater.subprocess, "run") as run:
            run.return_value = subprocess.CompletedProcess([], 0, "42\n", "")
            self.status.report("Downloading", "downloading", "t3code", 50)
            self.status.report("Ready", "ready")
            initial = run.call_args_list[0].args[0]
            final = run.call_args_list[1].args[0]
            self.assertIn("--hint=int:value:50", initial)
            self.assertIn("--replace-id=42", final)
            self.assertIn("--expire-time=8000", final)

    def test_absent_notification_server_is_nonfatal(self):
        self.status.notify = True
        with patch.object(updater.subprocess, "run", side_effect=FileNotFoundError):
            self.status.report("Checking", "checking", "codex")
        self.assertFalse(self.status.notify)
        self.assertEqual(json.loads(self.status.path.read_text())["phase"], "checking")

    def test_nightly_selection_ignores_stable_preview_and_draft(self):
        def release(tag, published, draft=False):
            return {"tag_name": tag, "published_at": published, "draft": draft,
                    "assets": [{"name": f"T3-Code-{tag.removeprefix('v')}-x86_64.AppImage",
                                "digest": "sha256:" + "a" * 64}]}
        releases = [release("v1.0.0", "2026-10-06"),
                    release("v1.0.0-preview.2", "2026-10-06"),
                    release("v1.0.0-nightly.2", "2026-10-06", True),
                    release("v1.0.0-nightly.1", "2026-10-05")]
        with patch.object(updater, "request", return_value=io.BytesIO(json.dumps(releases).encode())):
            tag, _ = updater.release("t3code")
        self.assertEqual(tag, "v1.0.0-nightly.1")

    def test_waiting_reports_lock_without_clobbering_active_status(self):
        data = self.base / "agent-tools"
        data.mkdir()
        for tool in updater.LABELS:
            # Use the same helpers with a temporary base matching the CLI's XDG layout.
            previous = self.base
            self.base = data
            root = self.old_install(tool)
            (root / ".last-check").touch()
            self.base = previous
        recorded = '{"phase":"downloading","percent":33}\n'
        (data / "status.json").write_text(recorded)
        env = dict(os.environ, XDG_DATA_HOME=str(self.base))
        with (data / ".update.lock").open("a") as lock:
            fcntl.flock(lock, fcntl.LOCK_EX)
            process = subprocess.Popen(
                [sys.executable, str(SCRIPT), "--max-age", "300"],
                env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True,
            )
            try:
                self.assertIn("Waiting for the update", process.stderr.readline())
                self.assertEqual((data / "status.json").read_text(), recorded)
            finally:
                fcntl.flock(lock, fcntl.LOCK_UN)
                out, err = process.communicate(timeout=10)
        self.assertEqual(process.returncode, 0, err)
        self.assertEqual(out, "")  # Never contaminate Codex app-server's stdout protocol.
        self.assertEqual(json.loads((data / "status.json").read_text())["phase"], "ready")


if __name__ == "__main__":
    unittest.main()
