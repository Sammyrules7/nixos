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
      description = "Only lock on idle, no dpms off or hibernate";
    };
  };

  config = lib.mkIf config.features.hyprland.hypridle.enable {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          lock_cmd = "hyprlock";
        };

        listener = lib.mkMerge [
          [
            {
              timeout = 300;
              on-timeout = "hyprlock";
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
              on-timeout = "systemctl hibernate";
            }
          ])
        ];
      };
    };
  };
}
