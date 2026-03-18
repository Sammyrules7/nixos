{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.features.hyprland.hyprlock.enable = lib.mkEnableOption "Hyprlock screen locker";

  config = lib.mkIf config.features.hyprland.hyprlock.enable {
    programs.hyprlock = {
      enable = true;
      settings = lib.mkForce {
        general = {
          disable_loading_bar = true;
          hide_cursor = true;
          no_fade_in = false;
        };

        background = [
          {
            path = "screenshot"; # only png supported for now
            color = "rgba(25, 20, 20, 1.0)";
            blur_passes = 3; # increased for better effect
            noise = 0.0117;
            contrast = 0.8916;
            brightness = 0.8172;
            vibrancy = 0.1696;
            vibrancy_darkness = 0.0;
          }
        ];

        input-field = [
          {
            size = "200, 50";
            outline_thickness = 3;
            dots_size = 0.33; # Scale of input-field height, 0.2 - 0.8
            dots_spacing = 0.15; # Scale of dots' absolute size, 0.0 - 1.0
            dots_center = true;
            outer_color = "rgb(151515)";
            inner_color = "rgb(200, 200, 200)";
            font_color = "rgb(10, 10, 10)";
            fade_on_empty = true;
            placeholder_text = "<i>Input Password...</i>"; # String rendered in input box
            hide_input = false;
            position = "0, -20";
            halign = "center";
            valign = "center";
          }
        ];

        label = [
          {
            text = "$TIME";
            color = "rgba(200, 200, 200, 1.0)";
            font_size = 64;
            font_family = "JetBrainsMono Nerd Font Mono";
            position = "0, 80";
            halign = "center";
            valign = "center";
          }
        ];
      };
    };

    wayland.windowManager.hyprland.settings.permission = lib.mkAfter [
      " .*hyprlock*. , screencopy, allow"
    ];
  };
}
