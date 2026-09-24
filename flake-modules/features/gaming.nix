{ ... }:

{
  flake.modules = {
    nixos.gaming = {
      imports = [
        ./_gaming/nixos/steam.nix
        ./_gaming/nixos/sunshine.nix
        ./_gaming/nixos/vr.nix
      ];
    };

    homeManager.gaming = {
      imports = [
        ./_gaming/home/minecraft.nix
        ./_gaming/home/moonlight.nix
      ];
    };
  };
}
