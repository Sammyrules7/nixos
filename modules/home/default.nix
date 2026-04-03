{
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hyprland
    ./kdeconnect.nix
    ./ghostty.nix
    ./btop.nix
    ./fish.nix
    ./theming.nix
    ./walker.nix
    ./mako.nix
    ./vesktop.nix
    ./voxtype.nix
    ./worktree-tool.nix
    ./zed.nix
  ];

  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
}
