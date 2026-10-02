{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.features.theming = {
    scaling = lib.mkOption {
      type = lib.types.float;
      default = 1.0;
      description = "Per-device scaling factor";
    };
  };

  config = {
    home.pointerCursor.enable = true;

    # Walker is the launcher; the unused Stylix Rofi target still sets the
    # deprecated programs.rofi.font option in our pinned Stylix version.
    stylix.targets.rofi.enable = false;

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        text-scaling-factor = lib.mkForce config.features.theming.scaling;
      };
    };

    gtk = {
      enable = true;
      iconTheme = {
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
      };
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
