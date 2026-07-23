{ ... }:

{
  flake.modules = {
    nixos.desktop-environment = {
      imports = [
        ./_desktop-environment/nixos/hyprland.nix
        ./_desktop-environment/nixos/kdeconnect.nix
        ./_desktop-environment/nixos/stylix.nix
        ./_desktop-environment/nixos/swayosd.nix
      ];
    };

    homeManager.desktop-environment = {
      imports = [
        ./_desktop-environment/home/hyprland
        ./_desktop-environment/home/kdeconnect.nix
        ./_desktop-environment/home/mako.nix
        ./_desktop-environment/home/swayosd.nix
        ./_desktop-environment/home/theming.nix
        ./_desktop-environment/home/walker.nix
        ./_desktop-environment/home/wluma.nix
      ];
    };
  };
}
