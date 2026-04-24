{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.features.gaming.minecraft.enable = lib.mkEnableOption "Minecraft (Prism Launcher)";

  config = lib.mkIf config.features.gaming.minecraft.enable {
    home.packages =  with pkgs; [
      prismlauncher
    ];
  };
}
