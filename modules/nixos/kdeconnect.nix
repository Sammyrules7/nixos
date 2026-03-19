{ config, lib, pkgs, ... }:

{
  options.features.kdeconnect.enable = lib.mkEnableOption "KDE Connect";

  config = lib.mkIf config.features.kdeconnect.enable {
    programs.kdeconnect.enable = true;
  };
}
