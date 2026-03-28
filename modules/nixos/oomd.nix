{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.features.oomd.enable = lib.mkEnableOption "OOMD configuration";

  config = lib.mkIf config.features.oomd.enable {

    services.earlyoom = {
      enable = true;
      enableNotifications = true;
      freeMemThreshold = 10;
      freeMemKillThreshold = 5;

      extraArgs = [
        "-g"
        "-p"
        "--prefer"
        ".*(ollama|llama|electron|chrome|chromium|firefox|zen|helium|vesktop)$"
        "--avoid"
        ".*(Hyprland|hyprland|waybar|Xwayland|ghostty|walker)$"
      ];
    };

    services.systembus-notify.enable = true;
    environment.systemPackages = [ pkgs.libnotify ];
  };
}
