{ pkgs, ... }:

{
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      text-scaling-factor = 0.75;
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    gtk2.extraConfig = "gtk-xft-dpi = 73728";
    gtk3.extraConfig = {
      gtk-xft-dpi = 73728;
    };
    gtk4.extraConfig = {
      gtk-xft-dpi = 73728;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "adwaita-dark";
  };

  home.sessionVariables = {
    GTK_THEME = "Adwaita-dark";
    QT_QPA_PLATFORMTHEME = "gtk2";

    # Scaling
    GDK_DPI_SCALE = "0.75";
    QT_SCALE_FACTOR = "0.75";
    QT_FONT_DPI = "72";

    # Wayland
    NIXOS_OZONE_WL = "1";
    SDL_VIDEODRIVER = "wayland";
  };

  xresources.properties = {
    "Xft.dpi" = 72;
  };
}
