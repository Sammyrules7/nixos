{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.features.theming = {
    enable = lib.mkEnableOption "Desktop environment theming";
    scaling = lib.mkOption {
      type = lib.types.float;
      default = 1.0;
      description = "Per-device scaling factor";
    };
  };

  config = lib.mkIf config.features.theming.enable {
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        text-scaling-factor = lib.mkForce config.features.theming.scaling;
      };
    };

    gtk = {
      enable = true;
      gtk4.theme = config.gtk.theme;
      # theme, gtk-xft-dpi etc. will be handled by Stylix if needed
    };

    home.sessionVariables = {
      # Scaling
      GDK_DPI_SCALE = builtins.toString config.features.theming.scaling;
      QT_SCALE_FACTOR = builtins.toString config.features.theming.scaling;
      QT_FONT_DPI = "72";

      # Wayland
      NIXOS_OZONE_WL = "1";
      SDL_VIDEODRIVER = "wayland";
    };

    xresources.properties = {
      "Xft.dpi" = 72;
    };
  };
}
