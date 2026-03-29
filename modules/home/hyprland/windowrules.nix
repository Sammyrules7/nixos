{ lib, ... }:

{
  wayland.windowManager.hyprland.settings = {
    extraConfigs = lib.mkAfter "

    windowrule = match:class osu!, immediate yes

      windowrule {
          # Ignore maximize requests from all apps. You'll probably like this.
          name = suppress-maximize-events
          match:class = .*

          suppress_event = maximize
      }

      windowrule {
          # Fix some dragging issues with XWayland
          name = fix-xwayland-drags
          match:class = ^$
          match:title = ^$
          match:xwayland = true
          match:float = true
          match:fullscreen = false
          match:pin = false

          no_focus = true
      }

      # Hyprland-run windowrule
      windowrule {
          name = move-hyprland-run

          match:class = hyprland-run

          move = 20 monitor_h-120
          float = yes
      }

      # Walker
      layerrule {
          name = walker-blur
          match:namespace = ^(walker)$
          blur = on
          ignore_alpha = 0
      }

      # Waybar
      layerrule {
          name = waybar-blur
          match:namespace = ^(waybar)$
          blur = on
          xray = off
          ignore_alpha = 0.005
      }

      # Mako
      layerrule {
          name = mako-blur
          match:namespace = ^(notifications)$
          blur = on
          xray = off
          ignore_alpha = 0
      }
    ";
  };
}
