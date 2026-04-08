{ config, lib, pkgs, ... }:

{
  options.features.gnome-files.enable = lib.mkEnableOption "GNOME Files (Nautilus)";

  config = lib.mkIf config.features.gnome-files.enable {
    home.packages = [ pkgs.nautilus ];
  };
}
