{
  wayland.windowManager.hyprland.settings = {
    window_rule = [
      {
        name = "osu-immediate";
        match.class = "osu!";
        immediate = true;
      }
      {
        name = "suppress-maximize-events";
        match.class = ".*";
        suppress_event = "maximize";
      }
      {
        name = "fix-xwayland-drags";
        match = {
          class = "^$";
          title = "^$";
          xwayland = true;
          float = true;
          fullscreen = false;
          pin = false;
        };
        no_focus = true;
      }
      {
        name = "move-hyprland-run";
        match.class = "hyprland-run";
        move = "20 monitor_h-120";
        float = true;
      }
    ];

    layer_rule = [
      {
        name = "walker-blur";
        match.namespace = "^(walker)$";
        blur = true;
        ignore_alpha = 0;
      }
      {
        name = "waybar-blur";
        match.namespace = "^(waybar)$";
        blur = true;
        xray = false;
        ignore_alpha = 0.005;
      }
      {
        name = "mako-blur";
        match.namespace = "^(notifications)$";
        blur = true;
        xray = false;
        ignore_alpha = 0;
      }
      {
        name = "swayosd-blur";
        match.namespace = "^(swayosd)$";
        blur = true;
        xray = false;
        ignore_alpha = 0;
      }
    ];
  };
}
