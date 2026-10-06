"""Repair the laptop's EFI filesystem or renew its existing TPM binding as root."""

import argparse
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import subprocess
import sys


def run(*args, **kwargs):
    return subprocess.run(args, check=True, **kwargs)


def tpm_options(metadata):
    tokens = list(metadata.get("tokens", {}).values())
    tpm_tokens = [token for token in tokens if token.get("type") == "systemd-tpm2"]
    if not tpm_tokens:
        raise ValueError("No existing TPM enrollment to renew.")
    policies = []
    for token in tpm_tokens:
        if token.get("tpm2-public-key") or token.get("tpm2-public-key-pcrs") or token.get("tpm2-pcrlock"):
            raise ValueError("Signed/PCR-lock policies need their original policy tooling; refusing to replace them.")
        pcrs = token.get("tpm2-pcrs")
        bank = token.get("tpm2-pcr-bank")
        if not pcrs or any(type(pcr) is not int or not 0 <= pcr <= 23 for pcr in pcrs):
            raise ValueError("Missing or invalid PCR binding; refusing to weaken the policy.")
        if 11 in pcrs or 15 in pcrs:
            raise ValueError("Boot-phase/volume PCR bindings must be renewed in the matching boot phase.")
        if bank not in ("sha1", "sha256", "sha384", "sha512"):
            raise ValueError("Unknown PCR bank; refusing to change the policy.")
        policies.append((tuple(sorted(pcrs)), bank, bool(token.get("tpm2-pin", False))))
    if len(set(policies)) != 1:
        raise ValueError("Multiple different TPM policies exist; inspect them before renewal.")
    # Keep a password/recovery slot independent of TPM enrollment.
    tpm_slots = {slot for token in tpm_tokens for slot in token.get("keyslots", [])}
    other_token_slots = {
        slot for token in tokens if token.get("type") not in ("systemd-tpm2", "systemd-recovery")
        for slot in token.get("keyslots", [])
    }
    fallback_slots = set(metadata.get("keyslots", {})) - tpm_slots - other_token_slots
    if not fallback_slots:
        raise ValueError("No independent password/recovery slot found; refusing to modify TPM enrollment.")
    pcrs, bank, pin = policies[0]
    return [f"--tpm2-pcrs={'+'.join(f'{pcr}:{bank}' for pcr in pcrs)}",
            f"--tpm2-with-pin={'yes' if pin else 'no'}"]


def backup_directory():
    directory = Path("/var/backups/laptop-maintenance") / datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S.%fZ")
    directory.mkdir(parents=True, mode=0o700)
    return directory


def renew_tpm(device):
    metadata = json.loads(run("cryptsetup", "luksDump", "--dump-json-metadata", device,
                              capture_output=True, text=True).stdout)
    options = tpm_options(metadata)
    # cryptenroll automatically discovers signed-policy keys. Avoid accidentally
    # changing an existing direct-PCR binding into a different policy.
    for directory in ("/etc/systemd", "/run/systemd", "/usr/lib/systemd"):
        if (Path(directory) / "tpm2-pcr-public-key.pem").exists():
            raise ValueError("A signed-PCR public key exists; use its original enrollment tooling.")
    if any(Path(path).exists() for path in ("/run/systemd/pcrlock.json", "/var/lib/systemd/pcrlock.json")):
        raise ValueError("A PCR-lock policy exists; use its original enrollment tooling.")
    backup = backup_directory() / "luks-header.img"
    run("cryptsetup", "luksHeaderBackup", device, "--header-backup-file", str(backup))
    backup.chmod(0o600)
    print(f"LUKS header backup: {backup}", flush=True)
    print("Renewing the existing PCR binding: " + " ".join(options), flush=True)
    # Combined enrollment/wiping creates the new slot before removing old TPM
    # slots. Password and recovery slots remain available if enrollment fails.
    run("systemd-cryptenroll", "--tpm2-device=auto", "--wipe-slot=tpm2", *options, device)


def repair_boot(device):
    mount = json.loads(run("findmnt", "--json", "--mountpoint", "/boot", "--output", "SOURCE,FSTYPE",
                          capture_output=True, text=True).stdout)["filesystems"][0]
    if mount["fstype"] != "vfat" or Path(mount["source"]).resolve() != Path(device).resolve():
        raise ValueError("/boot does not match the configured EFI partition.")
    backup = backup_directory() / "efi-partition.img"
    run("umount", "/boot")  # Fails safely if a bootloader update is using it.
    try:
        # A complete image preserves the original FAT before any repair writes.
        with backup.open("xb") as output:
            os.fchmod(output.fileno(), 0o600)
            run("dd", f"if={device}", "bs=4M", "iflag=fullblock", "status=progress", stdout=output)
            output.flush()
            os.fsync(output.fileno())
        print(f"EFI partition backup: {backup}", flush=True)
        repaired = subprocess.run(["fsck.fat", "-a", device])
        if repaired.returncode not in (0, 1):
            raise RuntimeError(f"EFI repair failed with exit code {repaired.returncode}.")
        run("fsck.fat", "-n", device)
    finally:
        run("mount", "/boot")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=("boot", "tpm", "health"))
    parser.add_argument("--luks-device", required=True)
    parser.add_argument("--boot-device", required=True)
    args = parser.parse_args()
    if os.geteuid() != 0:
        parser.error("Root access is required; run sudo laptop-maintenance <action> from your terminal.")
    os.umask(0o077)
    if args.action == "boot":
        repair_boot(args.boot_device)
    elif args.action == "tpm":
        renew_tpm(args.luks_device)
    else:
        run("smartctl", "-a", "/dev/nvme0")
        run("btrfs", "device", "stats", "/home")


if __name__ == "__main__":
    try:
        main()
    except (ValueError, RuntimeError, subprocess.CalledProcessError) as error:
        print(f"Maintenance failed: {error}", file=sys.stderr)
        sys.exit(1)
