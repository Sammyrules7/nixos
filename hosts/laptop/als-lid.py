"""Pause wluma on lid close; reset IIO on open without a fixed wake delay.

Read only the lid switch input device. Do not grab it: logind still handles sleep.
"""

import fcntl
import glob
from pathlib import Path
import signal
import struct
import subprocess
import sys
import time

USER = sys.argv[1]
UID = sys.argv[2]
EVENT = struct.Struct("@llHHi")
PENDING = Path(f"/run/framework-als-wluma-{UID}")


def userctl(*args):
    return subprocess.run(
        ["runuser", "-u", USER, "--", "env", f"XDG_RUNTIME_DIR=/run/user/{UID}",
         "systemctl", "--user", *args],
        timeout=15,
        check=False,
    )


def wait_for_desktop():
    # A lid-open input event can precede systemd thawing user.slice. Do not send
    # user D-Bus requests or rebind hardware while the suspend unit is still busy.
    deadline = time.monotonic() + 10
    while time.monotonic() < deadline:
        frozen = subprocess.run(
            ["systemctl", "show", "user.slice", "-p", "FreezerState", "--value"],
            capture_output=True, text=True, timeout=2, check=True,
        ).stdout.strip()
        sleep_state = subprocess.run(
            ["systemctl", "show", "systemd-suspend.service", "-p", "ActiveState", "--value"],
            capture_output=True, text=True, timeout=2, check=True,
        ).stdout.strip()
        if frozen == "running" and sleep_state in ("inactive", "failed"):
            return
        time.sleep(0.05)
    raise RuntimeError("Desktop did not thaw after suspend")


def restore_wluma():
    if PENDING.exists() and userctl("start", "wluma.service").returncode == 0:
        PENDING.unlink(missing_ok=True)


def recover(reason="lid"):
    if any("closed" in Path(p).read_text() for p in glob.glob("/proc/acpi/button/lid/*/state")):
        return
    wait_for_desktop()
    # Lid-open and system-resume can arrive together. Serialize and coalesce them.
    with open("/run/framework-als-recovery.lock", "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        stamp = Path("/run/framework-als-last-reset")
        if stamp.exists():
            last_time, last_reason = stamp.read_text().split()
            if last_reason != reason and time.monotonic() - float(last_time) < 2:
                print("ALS already recovered for this wake", flush=True)
                restore_wluma()
                return
        driver = Path("/sys/bus/hid/drivers/hid-sensor-hub")
        # Framework's ALS hub only; instance numbers change after a driver rebind.
        devices = list(driver.glob("*:32AC:001B.*"))
        if not devices:
            raise RuntimeError("Framework ALS HID hub not found")
        running = PENDING.exists() or userctl("is-active", "--quiet", "wluma.service").returncode == 0
        proxy_running = subprocess.run(
            ["systemctl", "is-active", "--quiet", "iio-sensor-proxy.service"],
            timeout=15, check=False,
        ).returncode == 0
        try:
            # A graceful stop releases capture buffers; SIGSTOP can retain an
            # in-flight Wayland/Vulkan frame during the display's suspend path.
            if running:
                PENDING.touch()
                if userctl("stop", "wluma.service").returncode != 0:
                    raise RuntimeError("Could not stop wluma before ALS reset")
            if proxy_running:
                subprocess.run(["systemctl", "stop", "iio-sensor-proxy.service"],
                               timeout=15, check=True)
            for device in devices:
                (driver / "unbind").write_text(device.name + "\n")
                (driver / "bind").write_text(device.name + "\n")
                print(f"Rebound Framework ALS hub {device.name}", flush=True)
            stamp.write_text(f"{time.monotonic()} {reason}\n")
        finally:
            if proxy_running:
                subprocess.run(["systemctl", "start", "iio-sensor-proxy.service"],
                               timeout=15, check=False)
            if running:
                restore_wluma()


def main():
    def terminate(_signum, _frame):
        raise SystemExit(0)

    signal.signal(signal.SIGTERM, terminate)
    if "--recover" in sys.argv:
        recover("resume")
        return
    for entry in glob.glob("/sys/class/input/event*/device/name"):
        if Path(entry).read_text().strip() == "Lid Switch":
            event = Path(entry).parents[1].name
            break
    else:
        raise RuntimeError("Lid Switch input device not found")
    try:
        with open(f"/dev/input/{event}", "rb", buffering=0) as device:
            while True:
                data = device.read(EVENT.size)
                if len(data) != EVENT.size:
                    raise RuntimeError("Lid switch input device disappeared")
                _, _, kind, code, value = EVENT.unpack(data)
                if kind != 5 or code != 0:  # EV_SW / SW_LID
                    continue
                if value == 1:
                    print("Lid closed: pausing wluma", flush=True)
                    if userctl("is-active", "--quiet", "wluma.service").returncode == 0:
                        PENDING.touch()
                        if userctl("stop", "wluma.service").returncode != 0:
                            raise RuntimeError("Could not pause wluma on lid close")
                else:
                    print("Lid opened: recovering ALS", flush=True)
                    recover()
    finally:
        restore_wluma()


if __name__ == "__main__":
    main()
