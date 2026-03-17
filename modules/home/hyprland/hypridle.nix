{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.features.hyprland.hypridle.enable = lib.mkEnableOption "Hypridle daemon";

  config = lib.mkIf config.features.hyprland.hypridle.enable {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          lock_cmd = "hyprlock";
        };

        listener = [
          {
            timeout = 300; # 5min
            on-timeout = "hyprlock";
          }
          {
            timeout = 330; # 5.5min
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = 1800; # 30min
            on-timeout = "systemctl hibernate";
          }
        ];
      };
    };
  };
}
