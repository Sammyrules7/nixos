{
  wayland.windowManager.hyprland.settings = {
    ecosystem.enforce_permissions = 1;
    permission = [
      # Match the binary name regardless of the Nix store prefix
      "grim, screencopy, allow"
      "xdg-desktop-portal-hyprland, screencopy, allow"
      "hyprpm, plugin, allow"
    ];
  };
}
