{ pkgs, ... }:

{
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  home.sessionVariables = {
    # Wayland
    NIXOS_OZONE_WL = "1";
    SDL_VIDEODRIVER = "wayland";
  };
}
