{ config, lib, pkgs, ... }:

{
  options.features.showtime.enable = lib.mkEnableOption "Showtime video player";

  config = lib.mkIf config.features.showtime.enable {
    home.packages = [ pkgs.showtime ];
  };
}
