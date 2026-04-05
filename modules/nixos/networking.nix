{ config, lib, ... }:

{
  options.features.networking.enable = lib.mkEnableOption "Networking configuration";

  config = lib.mkIf config.features.networking.enable {
    networking.networkmanager.enable = true;
    networking.nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
      "2606:4700:4700::1111"
    ];
    systemd.services.NetworkManager-wait-online.enable = false;

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = false;
    };
  };
}
