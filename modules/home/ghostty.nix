{ config, lib, ... }:

{
  options.features.ghostty.enable = lib.mkEnableOption "Ghostty terminal emulator";

  config = lib.mkIf config.features.ghostty.enable {
    programs.ghostty = {
      enable = true;
      settings = {
        font-family = "JetBrainsMono Nerd Font";
        window-decoration = false;
        background-opacity = 0;
        shell-integration = "fish";
      };
    };
  };
}
