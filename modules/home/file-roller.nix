{ config, lib, pkgs, ... }:

{
  options.features.file-roller.enable = lib.mkEnableOption "File Roller";

  config = lib.mkIf config.features.file-roller.enable {
    home.packages = [ pkgs.file-roller ];
  };
}