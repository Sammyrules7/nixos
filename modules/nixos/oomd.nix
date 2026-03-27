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
      freeMemThreshold = 5;
      freeMemKillThreshold = 2;

      extraArgs = [
        "-g"
        "-p"
        "--prefer"
        "^(electron|chrome|chromium|firefox|zen|helium|vesktop)$"
        "--avoid"
        "^(hyprland|hyprpanel|Xwayland|ghostty|walker)$"
      ];
    };

    services.systembus-notify.enable = true;
    environment.systemPackages = [ pkgs.libnotify ];
  };
}
