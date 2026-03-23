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
          no_fade_out = false;
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
            size = "250, 60";
            outline_thickness = 2;
            dots_size = 0.2; # Scale of input-field height, 0.2 - 0.8
            dots_spacing = 0.2; # Scale of dots' absolute size, 0.0 - 1.0
            dots_center = true;
            outer_color = "rgba(255, 255, 255, 0)";
            inner_color = "rgba(255, 255, 255, 0.1)";
            font_color = "rgb(200, 200, 200)";
            fade_on_empty = true;
            placeholder_text = "󰟀  <i>Fingerprint or Password</i>";
            hide_input = false;
            rounding = -1; # Circular
            check_color = "rgb(204, 136, 34)";
            fail_color = "rgb(204, 34, 34)";
            fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
            fail_transition = 300;
            position = "0, -120";
            halign = "center";
            valign = "center";
          }
        ];

        auth = {
          "fingerprint:enabled" = true;
        };

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
