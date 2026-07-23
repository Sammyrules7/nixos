{ ... }:

{
  flake.modules.nixos.platform-services = {
    imports = [
      ./_platform-services/nixos/flatpak.nix
      ./_platform-services/nixos/fprintd.nix
      ./_platform-services/nixos/ollama.nix
      ./_platform-services/nixos/power.nix
      ./_platform-services/nixos/sops.nix
      ./_platform-services/nixos/ssh.nix
      ./_platform-services/nixos/tailscale.nix
      ./_platform-services/nixos/upgrade.nix
    ];

    features.upgrade.enable = false;
  };
}
