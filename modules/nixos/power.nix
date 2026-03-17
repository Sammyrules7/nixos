{ config, lib, pkgs, ... }:

{
  options.features.power.enable = lib.mkEnableOption "Power management configuration";

  config = lib.mkIf config.features.power.enable {
    # Power management for laptops (lid switch, battery, etc)
    services.logind = {
      lidSwitch = "suspend-then-hibernate";
      lidSwitchExternalPower = "suspend";
      extraConfig = ''
        HandlePowerKey=suspend
        IdleAction=suspend-then-hibernate
        IdleActionSec=20min
      '';
    };

    # System-wide hibernation setup
    # Suspend-then-hibernate config (delay before hibernating after suspending)
    systemd.sleep.extraConfig = ''
      HibernateDelaySec=15min
    '';
  };
}
