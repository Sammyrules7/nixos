# GEMINI.md - Project Context

## Project Overview
This repository contains a modular **NixOS and Home Manager configuration** built using **Nix Flakes**. It follows a feature-oriented design where system and user-level functionality is organized into independent, toggleable modules under a custom `features` option namespace.

### Key Technologies
- **NixOS**: System-level configuration.
- **Home Manager**: User-level configuration (managed as a NixOS module).
- **Flakes**: Dependency management and configuration entry point.
- **Hyprland**: Primary Wayland compositor.
- **Stylix**: Universal theming engine across applications and environments.
- **Ghostty**: Terminal emulator.
- **Walker**: Application runner/launcher.
- **Vesktop**: Discord client with enhancements.
- **Btop**: System monitor.

## Architecture

- `flake.nix`: The central entry point defining inputs and host configurations (`Desktop`, `Laptop`).
- `hosts/`: Machine-specific configurations.
  - `hosts/common/`: Shared settings used by all hosts, including common system and Home Manager features.
  - `hosts/desktop/`: Specific configuration for the desktop (Intel, NVIDIA 3060 ti 8Gb, 32gb ram).
  - `hosts/laptop/`: Specific configuration for the laptop (Framework 13 AMD 7040 edition,).
- `modules/`: Modular feature definitions.
  - `modules/nixos/`: System-level modules (Audio, Bluetooth, Networking, Steam, VR, etc.).
  - `modules/home/`: User-level modules (Hyprland, Theming, Btop, Walker, etc.).

## Building and Running

### Automated Deployment Script
Use the deploy script to automatically detect the machine and apply the configuration:

```bash
# Test configuration (dry-activate)
./scripts/deploy test

# Apply configuration (requires sudo)
./scripts/deploy switch
```

### Manual Deployment
Only use manual commands if the deploy script is unavailable:

```bash
# Test configuration
nixos-rebuild dry-activate --flake .#(Desktop|Laptop)

# Switch configuration
sudo nixos-rebuild switch --flake .#(Desktop|Laptop)
```

### Update Flake Inputs
```bash
nix flake update
```

## Development Conventions

### Feature Flags
Functionality is encapsulated in modules and enabled using the `features` option.
Example usage in a host or common file:
```nix
features.audio.enable = true;
features.hyprland.enable = true;
```

### Module Structure
Each feature module typically resides in its own file within `modules/nixos/` or `modules/home/` and defines:
- `options.features.<name>.enable`: A boolean to toggle the feature.
- `config`: The actual configuration applied if the toggle is enabled (`lib.mkIf`).

### User Configuration
The primary user is `sammy`. Home Manager is integrated directly into the NixOS configuration via `home-manager.nixosModules.home-manager`. Home Manager modules are defined in `modules/home/` and toggled similarly to system modules.

### Formatting
- Use Nix language idioms.
- Maintain the modular structure when adding new software or system tweaks.
- Prefer adding options to `features` over ad-hoc configuration in `hosts/`.
