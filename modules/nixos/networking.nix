{ config, lib, ... }:

{
  options.features.networking.enable = lib.mkEnableOption "Networking configuration";

  config = lib.mkIf config.features.networking.enable {
    networking.networkmanager.enable = true;
    networking.nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
      "8.8.4.4"
      "9.9.9.9"
      "208.67.222.222"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
      "2001:4860:4860::8888"
      "2001:4860:4860::8844"
      "2620:fe::fe"
    ];
    systemd.services.NetworkManager-wait-online.enable = false;
  };
}
