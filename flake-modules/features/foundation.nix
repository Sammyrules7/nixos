{ ... }:

{
  flake.modules.nixos.foundation = {
    imports = [
      ./_foundation/nixos/core.nix
      ./_foundation/nixos/boot.nix
      ./_foundation/nixos/networking.nix
      ./_foundation/nixos/oomd.nix
      ./_foundation/nixos/audio.nix
      ./_foundation/nixos/bluetooth.nix
    ];

    nix.settings.download-buffer-size = 64 * 1024 * 1024;
  };
}
