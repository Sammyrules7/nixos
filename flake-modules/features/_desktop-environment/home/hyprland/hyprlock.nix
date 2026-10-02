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
          hide_cursor = true;
        };
        animations = {
          enabled = true;
          bezier = [
            "gentle, 0.22, 1, 0.36, 1"
            "blurRamp, 0.33, 0, 0.67, 1"
          ];
          animation = [
            # Hyprlock mixes the sharp screenshot with its cached blurred copy.
            # A gradual ramp keeps the transition visible without a long delay.
            "fadeIn, 1, 9, blurRamp"
            "fadeOut, 1, 3, blurRamp"
            "inputFieldColors, 1, 2, gentle"
          ];
        };

        background = [
          {
            path = "screenshot"; # only png supported for now
            color = "rgba(25, 20, 20, 1.0)";
            blur_passes = 3; # increased for better effect
            blur_size = 9;
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
            fade_on_empty = false;
            placeholder_text = "󰟀  <i>Fingerprint or Password</i>";
            hide_input = false;
            rounding = -1; # Circular
            check_color = "rgb(204, 136, 34)";
            fail_color = "rgb(204, 34, 34)";
            fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
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
            text = "$TIME12";
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
      {
        binary = ".*hyprlock.*";
        type = "screencopy";
        mode = "allow";
      }
    ];
  };
}
