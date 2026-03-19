{ config, lib, pkgs, ... }:

{
  options.features.kdeconnect.enable = lib.mkEnableOption "KDE Connect";

  config = lib.mkIf config.features.kdeconnect.enable {
    services.kdeconnect = {
      enable = true;
      indicator = true; # Adds the tray icon for KDE Connect
    };
  };
}
