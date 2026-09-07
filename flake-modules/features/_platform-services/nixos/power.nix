{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.features.power = {
    enable = lib.mkEnableOption "Power management configuration";
    mode = lib.mkOption {
      type = lib.types.enum [
        "aggressive"
        "minimal"
      ];
      default = "aggressive";
      description = "Power management mode: aggressive for laptops (max savings), minimal for desktops";
    };
  };

  config = lib.mkIf config.features.power.enable {
    services.power-profiles-daemon.enable = true;

    services.logind = lib.mkIf (config.features.power.mode == "aggressive") {
      settings.Login = {
        # These workstations use zram, without persistent swap for hibernation.
        HandleLidSwitch = "suspend";
        HandleLidSwitchExternalPower = "suspend";
        HandlePowerKey = "suspend";
        # Hypridle owns idle suspend and respects desktop idle inhibitors.
        IdleAction = "ignore";
      };
    };
  };
}
