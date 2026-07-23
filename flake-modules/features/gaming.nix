{ ... }:

{
  flake.modules = {
    nixos.gaming = {
      imports = [
        ./_gaming/nixos/steam.nix
        ./_gaming/nixos/vr.nix
      ];
    };

    homeManager.gaming = {
      imports = [ ./_gaming/home/minecraft.nix ];
    };
  };
}
