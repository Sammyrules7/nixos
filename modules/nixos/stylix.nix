{ pkgs, lib, ... }:

{
  stylix = {
    enable = true;
    image = pkgs.fetchurl {
      url = "https://github.com/AngelJumbo/gruvbox-wallpapers/raw/main/wallpapers/photography/beach.png";
      sha256 = "sha256-Uym/931m4K6JQDOJdSYuF2bglYGtGDUD/Qm8yY0xw3s=";
    };

    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };

    polarity = "dark";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.roboto-mono
  ];
}
