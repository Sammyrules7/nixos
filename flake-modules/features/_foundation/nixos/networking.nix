{ ... }:

{
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

  # NetworkManager and Tailscale can restart the NSS lookup targets several
  # times while DNS settles during boot. Keep nsncd from hitting the default
  # five-start limit during that handoff.
  systemd.services.nscd.unitConfig = {
    StartLimitIntervalSec = "30s";
    StartLimitBurst = 20;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = false;
  };
}
