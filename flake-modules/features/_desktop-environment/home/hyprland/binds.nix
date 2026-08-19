{ lib, ... }:

let
  lua = import ./lua.nix { inherit lib; };
  exec = command: lua.dispatcher "exec_cmd" command;
  window = lua.windowDispatcher;

  directions = [
    "left"
    "right"
    "up"
    "down"
  ];

  workspaces = builtins.genList (index: index + 1) 10;
  workspaceKey = workspace: builtins.toString (if workspace == 10 then 0 else workspace);
in
{
  wayland.windowManager.hyprland.settings.bind = [
    # Apps and window management
    (lua.bind "SUPER + return" (exec "ghostty"))
    (lua.bind "SUPER + SHIFT + T" (exec "ghostty -e btop"))
    (lua.bind "SUPER + SHIFT + F" (exec "nautilus"))
    (lua.bind "SUPER + W" (lua.windowDispatcher0 "close"))
    (lua.bind "SUPER + ALT + W" (lua.windowDispatcher0 "kill"))
    (lua.bind "SUPER + V" (window "float" { action = "toggle"; }))
    (lua.bind "SUPER + SPACE" (exec "walker"))
    (lua.bind "SUPER + ESCAPE" (exec "walker -m power"))
    (lua.bind "SUPER + SHIFT + L" (exec "systemctl hibernate"))
    (lua.bind "SUPER + L" (exec "hyprlock"))
    (lua.bind "SUPER + P" (lua.windowDispatcher0 "pseudo"))
    (lua.bind "SUPER + J" (lua.dispatcher "layout" ""))
    (lua.bind "SUPER + F" (lua.windowDispatcher0 "fullscreen"))
    (lua.bind "CONTROL + SUPER + SHIFT + Q" (
      exec "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl eval 'hl.dispatch(hl.dsp.exit())'"
    ))

    # Blue light filter toggle (wlsunset)
    (lua.bind "SUPER + N" (
      exec ''sh -c 'if systemctl --user is-active --quiet wlsunset.service; then systemctl --user stop wlsunset.service; swayosd-client --custom-message "Night Light Disabled" --custom-icon "display-brightness-symbolic"; else systemctl --user start wlsunset.service; swayosd-client --custom-message "Night Light Enabled" --custom-icon "night-light-symbolic"; fi''
    ))

    # Mako (notifications)
    (lua.bind "SUPER + comma" (exec "makoctl dismiss"))
    (lua.bind "SUPER + SHIFT + comma" (
      exec ''sh -c 'makoctl mode -t do-not-disturb; if makoctl mode | grep -q "do-not-disturb"; then swayosd-client --custom-message "DND Enabled" --custom-icon "notifications-disabled-symbolic"; else swayosd-client --custom-message "DND Disabled" --custom-icon "preferences-system-notifications-symbolic"; fi''
    ))
    (lua.bind "SUPER + ALT + comma" (exec "makoctl restore"))
    (lua.bind "SUPER + CONTROL + comma" (exec "makoctl invoke"))
    (lua.bind "SUPER + CONTROL + SHIFT + comma" (exec "makoctl dismiss -a"))
  ]
  ++ map (
    direction: lua.bind "SUPER + ${direction}" (lua.dispatcher "focus" { inherit direction; })
  ) directions
  ++ map (
    direction: lua.bind "SUPER + SHIFT + ${direction}" (window "swap" { inherit direction; })
  ) directions
  ++ map (
    workspace:
    lua.bind "SUPER + ${workspaceKey workspace}" (lua.dispatcher "focus" { inherit workspace; })
  ) workspaces
  ++ map (
    workspace:
    lua.bind "SUPER + SHIFT + ${workspaceKey workspace}" (window "move" { inherit workspace; })
  ) workspaces
  ++ map (
    workspace:
    lua.bind "SUPER + SHIFT + ALT + ${workspaceKey workspace}" (
      window "move" {
        inherit workspace;
        follow = false;
      }
    )
  ) workspaces
  ++ [
    # Mouse window movement and resizing
    (lua.bind "SUPER + mouse:272" (lua.windowDispatcher0 "drag"))
    (lua.bind "SUPER + mouse:273" (lua.windowDispatcher0 "resize"))

    # Media keys remain active while input is inhibited.
    (lua.bindWith "XF86AudioRaiseVolume" (exec "swayosd-client --output-volume raise") {
      locked = true;
    })
    (lua.bindWith "XF86AudioLowerVolume" (exec "swayosd-client --output-volume lower") {
      locked = true;
    })
    (lua.bindWith "XF86AudioMute" (exec "swayosd-client --output-volume mute-toggle") {
      locked = true;
    })
    (lua.bindWith "XF86AudioMicMute" (exec "swayosd-client --input-volume mute-toggle") {
      locked = true;
    })
    (lua.bindWith "XF86MonBrightnessUp" (exec "swayosd-client --brightness raise") { locked = true; })
    (lua.bindWith "XF86MonBrightnessDown" (exec "swayosd-client --brightness lower") { locked = true; })
    (lua.bindWith "XF86AudioNext" (exec "swayosd-client --playerctl next") { locked = true; })
    (lua.bindWith "XF86AudioPause" (exec "swayosd-client --playerctl play-pause") { locked = true; })
    (lua.bindWith "XF86AudioPlay" (exec "swayosd-client --playerctl play-pause") { locked = true; })
    (lua.bindWith "XF86AudioPrev" (exec "swayosd-client --playerctl prev") { locked = true; })
    (lua.bindWith "XF86AudioStop" (exec "swayosd-client --playerctl stop") { locked = true; })
    (lua.bindWith "XF86AudioForward" (exec "playerctl position 10+") { locked = true; })
    (lua.bindWith "XF86AudioRewind" (exec "playerctl position 10-") { locked = true; })
  ];
}
