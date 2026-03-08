{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hyprland
    ./ghostty.nix
    ./btop.nix
    ./theming.nix
  ];

  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.roboto-mono
  ];

  programs.vesktop.enable = true;
  programs.vesktop = {
    settings = {
      "discordBranch" = "stable";
      "minimizeToTray" = true;
      "arRPC" = true;
      "splashColor" = "rgb(220, 220, 223)";
      "splashBackground" = "rgb(0, 0, 0)";
      "hardwareVideoAcceleration" = false;
      "disableSmoothScroll" = false;
    };
    vencord = { };
  };
}
