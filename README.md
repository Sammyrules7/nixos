# Sammy's NixOS workstations

Its like vibecoded so have fun

This flake manages the `Desktop` and `Laptop` NixOS configurations with Home
Manager embedded into each system.

## Architecture

The flake uses the dendritic pattern:

- `flake.nix` declares inputs and evaluates the top-level module tree.
- `flake-modules/features/*.nix` owns a vertical concern and publishes typed
  NixOS and/or Home Manager modules.
- `flake-modules/features/_*/` contains private lower-level implementation
  modules. `import-tree` ignores underscore-prefixed paths.
- `flake-modules/profiles/workstation.nix` composes shared workstation policy.
- `flake-modules/users/sammy.nix` owns the primary user and Home Manager
  attachment.
- `hosts/` contains physical-machine facts and host-specific overrides.

Feature selection belongs in profiles. Hosts should contain only hardware facts
or genuine per-machine differences. Options under `features` are implementation
settings for the private modules and should not become another global feature
registry.

## Validation and deployment

```bash
nix flake check --no-build
./scripts/deploy test
./scripts/deploy switch
```

The deploy script detects the current hostname and selects the matching flake
configuration.

## Desktop shortcuts and laptop sleep

- `Super+J`: toggle the dwindle split direction.
- `Super+left mouse drag`: move a window; `Super+right mouse drag`: resize it.
- `Super+Escape`: power menu (lock, suspend, log out, reboot, power off).
- `Super+L`: lock; `Super+Shift+L`: suspend.
- Hold volume or brightness keys for repeated adjustments.

On the laptop, Hypridle locks after 5 minutes, turns displays off after 5½ minutes, and
suspends after 30 minutes unless an application inhibits idle. Sleep requests
also lock the session before sleeping. The laptop lid and power button suspend.
The desktop only locks on idle.
These machines have no persistent swap configured, so hibernation is not
available; zram alone cannot retain a hibernation image across power loss.

## Agent tools

Open **T3 Code Nightly** in the launcher. It checks upstream releases at launch,
and a user timer checks hourly in the background. Successful checks are reused
for five minutes to keep repeated launches fast. T3 uses the latest stable
Codex CLI from OpenAI's complete Linux package, including its helper binaries.
This is the same native package used by `github:sadjow/codex-cli-nix`, pulled
directly from upstream without waiting for that flake's hourly update. Terminal
`codex` launches also check for updates; npm/`npx` is not required.
T3 itself follows the nightly channel, excluding preview builds. No flake update
or NixOS rebuild is needed for these application updates.

Launcher updates show a desktop notification with the current stage, downloaded
size, percentage, speed, and estimated time remaining. The launcher uses the
upstream nightly icon, vendored from
[`pingdotgg/t3code` (MIT)](https://github.com/pingdotgg/t3code/blob/f4f148eb670622a049ae6561d7795011e383fc43/assets/nightly/nightly-universal-1024.png).

Downloads are checked against the release's SHA-256 digest before installation.
Updates switch version directories atomically; an offline launch uses the last
verified installation. Current and previous versions are retained, along with
any older version still used by a running process. Restart T3 to use an updated
desktop application. `agent-tools-update` forces a manual check;
`agent-tools-update --notify` also shows desktop progress. Use
`agent-tools-update --status` for the last update stage and installed versions,
or inspect the timer with `journalctl --user -u agent-tools-update`.

## Store maintenance and ambient light

The kernel command line deliberately omits `fastboot`: systemd interprets it as
an instruction to skip filesystem checks. The EFI filesystem is checked before
mounting at boot. The laptop uses the kernel's default IOMMU configuration so
the AMD NPU driver can initialize; the obsolete `amdgpu.fastboot` option is gone.

Ollama on the laptop explicitly enables integrated GPU inference. Model-download
retries start at 30 seconds and back off, and AC-power notifications are coalesced
before reconciling the service with the current mains state.

After switching and rebooting, `sudo laptop-maintenance boot` backs up the EFI
partition, unmounts it, repairs and verifies FAT, and remounts `/boot`.
`sudo laptop-maintenance health` prints SSD SMART and Btrfs device counters.
`sudo laptop-maintenance tpm` backs up the LUKS header and renews an existing
direct-PCR TPM enrollment using the same PCR bank, indexes and PIN requirement.
It preserves password/recovery slots and refuses signed, PCR-lock, differing or
boot-phase policies. Run TPM renewal **after booting the final configuration**;
it prompts locally for the disk passphrase and, when applicable, the TPM PIN.
Backups are private and retained under `/var/backups/laptop-maintenance`.

GC and store optimisation run on AC power with CPU, memory, bandwidth and IOPS
limits on the filesystem containing `/nix`. Optimisation runs weekly instead of
hashing every file during imports. The laptop builds one job with two cores.

The laptop pauses wluma on lid close and rebinds only the Framework ALS HID hub
on lid open and resume, without a fixed wake delay. Restarting the IIO proxy alone
did not recover this machine's stuck sensor; the targeted HID rebind did. wluma
polls twice per second and still accepts
zero lux in a dark room. A manually disabled wluma stays disabled. Inspect
`journalctl -u framework-als-lid -u framework-als-resume` for recovery logs.
Recovery waits for systemd to thaw the desktop and coalesces the lid-open and
resume events into one reset. wluma stops gracefully on lid close so it releases
its screen-capture buffers before suspend.

Workspace switching and window opening use a subtle spring curve. Hyprlock
crossfades from the sharp screenshot to its cached blurred copy over 0.9 seconds.

## Android development

Android Studio uses the Nix-managed SDK at `/etc/android-sdk`. The SDK keeps
Android platforms 34–36 and build tools 34.0.0, 35.0.0, and 36.1.0 for existing
projects, and adds the latest platform and build tools available in the pinned
Nixpkgs. They advance when the flake lock is updated. Godot retains its 35.0.0
AAPT2 override; Android Studio uses the latest packaged AAPT2. The SDK is
read-only, so add SDK versions in the Android Nix module rather than through
Android Studio's SDK Manager.

After switching the configuration, log out and back in. On the Pixel 8 Pro,
enable Developer options and USB debugging, connect it with a data-capable USB
cable, and accept the computer's debugging prompt. Check the connection with
`adb devices`, then select the phone in Android Studio's Run target menu. Create
a new project with the Empty Activity template to start a Kotlin/Jetpack Compose
app.

## Headless game streaming

Moonlight is installed on both machines. Only `Desktop` enables
`features.sunshine.enable`; its `encoder = "nvenc"` selects Sunshine's CUDA
build, which is required for NVIDIA hardware capture/encoding. The RTX 3060 Ti
encodes HEVC/H.265 but cannot encode AV1. Both clients prefer HEVC and hardware
decoding, with 60 fps, stereo audio, V-sync/frame pacing, and SDR. The laptop
defaults to its native 2256×1504 resolution at 40 Mbps; the desktop client uses
1080p at 30 Mbps. Change `features.moonlight.settings` in Home Manager to adjust
these preferences. Close Moonlight before activating changes. Activation merges
preferences into its writable Qt settings file, preserving certificates and
paired hosts.

The desktop starts Sunshine and a separate headless Sway session at boot, even
before a physical login. Sway supplies the virtual desktop Sunshine needs to
check capture and encoding before it runs application launch commands. Steam
stays off until you select **Steam Big Picture** or **Satisfactory** in Moonlight;
selecting **Desktop** does not start Steam. No manual start command, monitor, or
dummy plug is required. Steam uses Xwayland; native Wayland games can use the
same session's Wayland socket. Existing Steam per-game launch options still
apply. Sway resizes its virtual
output to the Moonlight client's requested mode on connection. Game audio goes
to a dedicated PipeWire sink rather than the desktop speakers. Streamed mouse
and keyboard input is enabled only in the streaming compositor; Hyprland ignores
those virtual devices.

Add `sammydesktop` manually in Moonlight: discovery does not cross Tailscale.
Streaming ports are opened on `tailscale0`, with UPnP disabled. The existing SSH
configuration already trusts that interface. A desktop timer maintains a
1200-byte route MTU to the laptop's Tailscale IPv4 address: full-size TCP replies
stalled on this network during setup. Other peers keep their normal MTU.
Sunshine's administration UI accepts only local clients; open it through an SSH
tunnel:

```bash
ssh -L 47990:127.0.0.1:47990 sammydesktop sleep infinity
# Open https://localhost:47990 and enter Moonlight's PIN.
```

Select **Steam Big Picture** for the whole Steam library, **Satisfactory** for
its direct launcher, or **Desktop** for troubleshooting. Additional Steam games
need no Nix changes: install them through Big Picture. Additional direct
launchers can be added to `services.sunshine.applications.apps`.

```bash
moonlight stream sammydesktop "Steam Big Picture"
tailscale ping sammydesktop       # Prefer a direct connection over a DERP relay.
ssh sammydesktop game-stream-host status
```

Steam permits one client instance per Unix user. Exit local Steam (including
its tray icon) before selecting a Steam app in Moonlight. The remote Steam
service refuses to start if Steam is already running locally. To return to
the physical desktop, use Moonlight's **Quit App** action, which stops the
remote Steam service, then open Steam locally. Save any running game first.
Simply disconnecting Moonlight leaves Steam and games running for reconnection.

`game-stream-host stop` stops the whole remote session, including Steam, Sway,
and Sunshine. `game-stream-host start` makes Sway and Sunshine available again;
Steam still starts only when selected in Moonlight. Run these locally or over
SSH, for example `ssh sammydesktop game-stream-host stop`.

For diagnostics, use `journalctl --user -u game-stream-session -u sunshine
-u game-stream-steam` on the desktop. The Sunshine settings and application list
are Nix-managed; credentials and Moonlight pairing keys stay outside the store.
Satisfactory is installed in the user's Steam library, outside Nix.
The initial Sunshine account is `sammy`; its generated password is stored only
on the desktop in `~/.config/sunshine/web-password` (mode 0600). The laptop is
already paired. Large transfers through Tailscale SSH still stalled during
testing, although Sunshine's HTTP/RTSP/video paths worked with the route fix.
The admin tunnel may be affected by that separate SSH limitation.
