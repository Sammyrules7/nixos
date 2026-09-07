{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.features.hyprland.hypridle = {
    enable = lib.mkEnableOption "Hypridle daemon";
    lockOnly = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Only lock on idle, no dpms off or suspend";
    };
  };

  config = lib.mkIf config.features.hyprland.hypridle.enable {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          before_sleep_cmd = "loginctl lock-session";
          inhibit_sleep = 3;
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          lock_cmd = "pidof hyprlock || hyprlock";
        };

        listener = lib.mkMerge [
          [
            {
              timeout = 300;
              on-timeout = "loginctl lock-session";
            }
          ]
          (lib.mkIf (!config.features.hyprland.hypridle.lockOnly) [
            {
              timeout = 330;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
            }
            {
              timeout = 1800;
              on-timeout = "systemctl suspend";
            }
          ])
        ];
      };
    };
  };
}
