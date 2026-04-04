{ config, lib, pkgs, ... }:

{
  options.features.kdeconnect.enable = lib.mkEnableOption "KDE Connect";

  config = lib.mkIf config.features.kdeconnect.enable {
    programs.kdeconnect.enable = true;

    networking.firewall = {
      allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
      allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
      checkReversePath = "loose";
    };
  };
}
