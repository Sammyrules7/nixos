{ config, lib, pkgs, ... }:

{
  options.features.gnome-image-viewer.enable = lib.mkEnableOption "Photo Viewer (Loupe)";

  config = lib.mkIf config.features.gnome-image-viewer.enable {
    home.packages = [ pkgs.loupe ];
  };
}