{ config, lib, ... }:

{
  options.features.bluetooth.enable = lib.mkEnableOption "Bluetooth configuration";

  config = lib.mkIf config.features.bluetooth.enable {
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
  };
}
