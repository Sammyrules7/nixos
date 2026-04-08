{
  wayland.windowManager.hyprland.settings = {

  "$mod" = "SUPER";

  bind = [

    # Apps
    "$mod, return, exec, ghostty"
    "$mod_SHIFT, T, exec, ghostty -e btop"
    "$mod_SHIFT, F, exec, nautilus"

    "$mod, W, killactive,"
    "$mod_ALT, W, forcekillactive"

    "$mod, V, togglefloating,"
    "$mod, SPACE, exec, walker"
    "$mod, ESCAPE, exec, walker -m power"
    "$mod_SHIFT, L, exec, systemctl hibernate"
    "$mod, L, exec, hyprlock"
    "$mod, P, pseudo,"
    "$mod, J, togglesplit,"
    "$mod, F, fullscreen"
    "CONTROL_$mod_SHIFT, Q, exec, \"command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit\""

    # Blue light filter toggle (wlsunset)
    "$mod, N, exec, sh -c 'if systemctl --user is-active --quiet wlsunset.service; then systemctl --user stop wlsunset.service; swayosd-client --custom-message \"Night Light Disabled\" --custom-icon \"display-brightness-symbolic\"; else systemctl --user start wlsunset.service; swayosd-client --custom-message \"Night Light Enabled\" --custom-icon \"night-light-symbolic\"; fi'"

    # Mako (notifications)
    "$mod, comma, exec, makoctl dismiss"
    "$mod_SHIFT, comma, exec, sh -c 'makoctl mode -t do-not-disturb; if makoctl mode | grep -q \"do-not-disturb\"; then swayosd-client --custom-message \"DND Enabled\" --custom-icon \"notifications-disabled-symbolic\"; else swayosd-client --custom-message \"DND Disabled\" --custom-icon \"preferences-system-notifications-symbolic\"; fi'"
    "$mod_ALT, comma, exec, makoctl restore"
    "$mod_CONTROL, comma, exec, makoctl invoke"
    "$mod_CONTROL_SHIFT, comma, exec, makoctl dismiss -a"

    # Move focus
    "$mod, left, movefocus, l"
    "$mod, right, movefocus, r"
    "$mod, up, movefocus, u"
    "$mod, down, movefocus, d"

    # Move window
    "$mod_SHIFT, left, swapwindow, l"
    "$mod_SHIFT, right, swapwindow, r"
    "$mod_SHIFT, up, swapwindow, u"
    "$mod_SHIFT, down, swapwindow, d"

    # Move workspace
    "$mod, 1, workspace, 1"
    "$mod, 2, workspace, 2"
    "$mod, 3, workspace, 3"
    "$mod, 4, workspace, 4"
    "$mod, 5, workspace, 5"
    "$mod, 6, workspace, 6"
    "$mod, 7, workspace, 7"
    "$mod, 8, workspace, 8"
    "$mod, 9, workspace, 9"
    "$mod, 0, workspace, 10"

    "$mod SHIFT, 1, movetoworkspace, 1"
    "$mod SHIFT, 2, movetoworkspace, 2"
    "$mod SHIFT, 3, movetoworkspace, 3"
    "$mod SHIFT, 4, movetoworkspace, 4"
    "$mod SHIFT, 5, movetoworkspace, 5"
    "$mod SHIFT, 6, movetoworkspace, 6"
    "$mod SHIFT, 7, movetoworkspace, 7"
    "$mod SHIFT, 8, movetoworkspace, 8"
    "$mod SHIFT, 9, movetoworkspace, 9"
    "$mod SHIFT, 0, movetoworkspace, 10"

    "$mod SHIFT ALT, 1, movetoworkspacesilent, 1"
    "$mod SHIFT ALT, 2, movetoworkspacesilent, 2"
    "$mod SHIFT ALT, 3, movetoworkspacesilent, 3"
    "$mod SHIFT ALT, 4, movetoworkspacesilent, 4"
    "$mod SHIFT ALT, 5, movetoworkspacesilent, 5"
    "$mod SHIFT ALT, 6, movetoworkspacesilent, 6"
    "$mod SHIFT ALT, 7, movetoworkspacesilent, 7"
    "$mod SHIFT ALT, 8, movetoworkspacesilent, 8"
    "$mod SHIFT ALT, 9, movetoworkspacesilent, 9"
    "$mod SHIFT ALT, 0, movetoworkspacesilent, 10"
  ];

  bindm = [
    "$mod, mouse:272, movewindow"
    "$mod, mouse:273, resizewindow"
  ];

  # Generic binds
  bindl = [
    ", XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise"
    ", XF86AudioLowerVolume, exec, swayosd-client --output-volume lower"
    ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
    ", XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle"
    ", XF86MonBrightnessUp, exec, swayosd-client --brightness raise"
    ", XF86MonBrightnessDown, exec, swayosd-client --brightness lower"
    ", XF86AudioNext, exec, swayosd-client --playerctl next"
    ", XF86AudioPause, exec, swayosd-client --playerctl play-pause"
    ", XF86AudioPlay, exec, swayosd-client --playerctl play-pause"
    ", XF86AudioPrev, exec, swayosd-client --playerctl prev"
    ", XF86AudioStop, exec, swayosd-client --playerctl stop"
    ", XF86AudioForward, exec, playerctl position 10+"
    ", XF86AudioRewind, exec, playerctl position 10-"
  ];
 };
}
