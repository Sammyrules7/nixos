{
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hyprland
    ./kdeconnect.nix
    ./kilocode.nix
    ./ghostty.nix
    ./btop.nix
    ./fish.nix
    ./theming.nix
    ./walker.nix
    ./mako.nix
    ./swayosd.nix
    ./vesktop.nix
    ./voxtype.nix
    ./worktree-tool.nix
    ./zed.nix
    ./gnome-files.nix
    ./gnome-image-viewer.nix
    ./showtime.nix
    ./file-roller.nix
  ];

  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
}
