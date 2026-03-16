{ config, lib, ... }:

{
  options.features.networking.enable = lib.mkEnableOption "Networking configuration";

  config = lib.mkIf config.features.networking.enable {
    networking.networkmanager.enable = true;
    systemd.services.NetworkManager-wait-online.enable = false;
  };
}
