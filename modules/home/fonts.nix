{ config, lib, pkgs, ... }:

{
  options.features.fonts.enable = lib.mkEnableOption "User fonts and icons";

  config = lib.mkIf config.features.fonts.enable {
    home.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.roboto-mono
      wlsunset
    ];
  };
}
