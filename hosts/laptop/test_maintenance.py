"""Verify that laptop repairs preserve recovery paths and require an unmounted ESP."""

import importlib.util
import io
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch
from contextlib import redirect_stdout


spec = importlib.util.spec_from_file_location("maintenance", Path(__file__).with_name("maintenance.py"))
maintenance = importlib.util.module_from_spec(spec)
spec.loader.exec_module(maintenance)


class MaintenanceTests(unittest.TestCase):
    def metadata(self, **changes):
        token = {"type": "systemd-tpm2", "keyslots": ["1"], "tpm2-pcrs": [7, 0],
                 "tpm2-pcr-bank": "sha256", "tpm2-pin": False}
        token.update(changes)
        return {"tokens": {"0": token}, "keyslots": {"0": {}, "1": {}}}

    def test_preserve_pcr_bank_binding_and_pin_requirement(self):
        self.assertEqual(maintenance.tpm_options(self.metadata()),
                         ["--tpm2-pcrs=0:sha256+7:sha256", "--tpm2-with-pin=no"])
        self.assertIn("--tpm2-with-pin=yes", maintenance.tpm_options(self.metadata(**{"tpm2-pin": True})))

    def test_refuse_missing_binding_and_signed_or_boot_phase_policy(self):
        for changes in ({"tpm2-pcrs": []}, {"tpm2-pcr-bank": "unknown"},
                        {"tpm2-public-key-pcrs": [11]}, {"tpm2-pcrlock": True},
                        {"tpm2-pcrs": [7, 11]}, {"tpm2-pcrs": [7, 15]}):
            with self.subTest(changes=changes), self.assertRaises(ValueError):
                maintenance.tpm_options(self.metadata(**changes))

    def test_refuse_renewal_without_independent_recovery_slot(self):
        metadata = self.metadata()
        del metadata["keyslots"]["0"]
        with self.assertRaisesRegex(ValueError, "password/recovery"):
            maintenance.tpm_options(metadata)

    def test_refuse_collapsing_different_policies(self):
        metadata = self.metadata()
        metadata["tokens"]["1"] = self.metadata(**{"tpm2-pcrs": [7]})["tokens"]["0"]
        with self.assertRaisesRegex(ValueError, "different TPM"):
            maintenance.tpm_options(metadata)

    def test_boot_repair_unmounts_and_backs_up_before_writing(self):
        calls = []
        with tempfile.TemporaryDirectory() as directory:
            backup = Path(directory)

            def run(*args, **kwargs):
                calls.append(args)
                if args[0] == "findmnt":
                    return subprocess.CompletedProcess(args, 0, json.dumps({"filesystems": [
                        {"source": "/dev/test-efi", "fstype": "vfat"}]}))
                if args[0] == "dd":
                    kwargs["stdout"].write(b"original EFI filesystem")
                if args[:2] == ("fsck.fat", "-n"):
                    raise subprocess.CalledProcessError(1, args)

            def repair(args):
                self.assertIn(("umount", "/boot"), calls)
                self.assertEqual((backup / "efi-partition.img").read_bytes(), b"original EFI filesystem")
                return subprocess.CompletedProcess(args, 0)

            with patch.object(maintenance, "run", side_effect=run), \
                 patch.object(maintenance, "backup_directory", return_value=backup), \
                 patch.object(maintenance.subprocess, "run", side_effect=repair), redirect_stdout(io.StringIO()):
                with self.assertRaises(subprocess.CalledProcessError):
                    maintenance.repair_boot("/dev/test-efi")
            self.assertEqual(calls[-1], ("mount", "/boot"))

    def test_wrong_partition_is_rejected_before_unmount(self):
        mount = {"filesystems": [{"source": "/dev/other", "fstype": "vfat"}]}
        with patch.object(maintenance, "run", return_value=subprocess.CompletedProcess([], 0, json.dumps(mount))) as run:
            with self.assertRaisesRegex(ValueError, "configured EFI"):
                maintenance.repair_boot("/dev/test-efi")
            self.assertEqual(run.call_count, 1)


if __name__ == "__main__":
    unittest.main()
