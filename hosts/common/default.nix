{ pkgs, inputs, ... }:

{
  imports = [
    ../../modules/nixos
  ];

  nix.settings.download-buffer-size = 524288000; # 500 MiB

  # --- Enable Core System Features ---
  features.core.enable = true;
  features.boot.enable = true;
  features.networking.enable = true;
  features.oomd.enable = true;
  features.audio.enable = true;
  features.bluetooth.enable = true;
  features.flatpak.enable = true;
  features.upgrade.enable = true;
  features.hyprland.enable = true;
  features.kdeconnect.enable = true;
  features.swayosd.enable = true;
  features.users.sammy.enable = true;

  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
  };

  # --- Home Manager User Features ---
  home-manager.users.sammy = {
    features.hyprland.enable = true;
    features.kdeconnect.enable = true;
    features.ghostty.enable = true;
    features.btop.enable = true;
    features.fish.enable = true;
    features.theming.enable = true;
    features.mako.enable = true;
    features.swayosd.enable = true;
    features.walker.enable = true;
    features.vesktop.enable = true;
    features.zed.enable = true;
    features.worktree-tool.enable = true;
  };
}
