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

The shared Home Manager profile installs:

- Codex CLI from `nixpkgs`
- T3 Code from `nixpkgs`
- Codex Desktop through the `ilysenko/codex-desktop-linux` Home Manager module

Codex Desktop does not have an official Linux release. The configured package is
a community Linux compatibility build derived from OpenAI's desktop app. Its
module pins the Codex CLI path so graphical launches do not depend on shell
`PATH`.
