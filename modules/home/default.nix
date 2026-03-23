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
    ./theming.nix
    ./walker.nix
    ./vesktop.nix
    ./voxtype.nix
    ./worktree-tool.nix
  ];

  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
}
