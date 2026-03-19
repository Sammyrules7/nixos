{ pkgs, inputs, ... }:

{
  imports = [
    ../../modules/nixos
  ];

  # --- Enable Core System Features ---
  features.core.enable = true;
  features.boot.enable = true;
  features.networking.enable = true;
  features.audio.enable = true;
  features.bluetooth.enable = true;
  features.flatpak.enable = true;
  features.upgrade.enable = true;
  features.hyprland.enable = true;
  features.kdeconnect.enable = true;
  features.users.sammy.enable = true;

  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  # --- Home Manager User Features ---
  home-manager.users.sammy = {
    features.hyprland.enable = true;
    features.kdeconnect.enable = true;
    features.ghostty.enable = true;
    features.btop.enable = true;
    features.theming.enable = true;
    features.walker.enable = true;
    features.vesktop.enable = true;
  };
}
