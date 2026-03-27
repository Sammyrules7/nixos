{ config, lib, pkgs, ... }:

{
  options.features.power.enable = lib.mkEnableOption "Power management configuration";

  config = lib.mkIf config.features.power.enable {
    services.power-profiles-daemon.enable = true;

    # Power management for laptops (lid switch, battery, etc)
    services.logind = {
      settings.Login = {
        HandleLidSwitch = "suspend-then-hibernate";
        HandleLidSwitchExternalPower = "suspend";
        HandlePowerKey = "suspend";
        IdleAction = "suspend-then-hibernate";
        IdleActionSec = "20min";
      };
    };

    # System-wide hibernation setup
    # Suspend-then-hibernate config (delay before hibernating after suspending)
    systemd.sleep.settings.Sleep = {
      HibernateDelaySec = "15min";
    };
  };
}
