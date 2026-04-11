{ config, lib, pkgs, ... }:

{
  options.features.power = {
    enable = lib.mkEnableOption "Power management configuration";
    mode = lib.mkOption {
      type = lib.types.enum [ "aggressive" "minimal" ];
      default = "aggressive";
      description = "Power management mode: aggressive for laptops (max savings), minimal for desktops";
    };
  };

  config = lib.mkIf config.features.power.enable {
    services.power-profiles-daemon.enable = true;

    services.logind = lib.mkIf (config.features.power.mode == "aggressive") {
      settings.Login = {
        HandleLidSwitch = "suspend-then-hibernate";
        HandleLidSwitchExternalPower = "suspend";
        HandlePowerKey = "suspend";
        IdleAction = "suspend-then-hibernate";
        IdleActionSec = "20min";
      };
    };

    systemd.sleep.settings.Sleep = lib.mkIf (config.features.power.mode == "aggressive") {
      HibernateDelaySec = "15min";
    };
  };
}
