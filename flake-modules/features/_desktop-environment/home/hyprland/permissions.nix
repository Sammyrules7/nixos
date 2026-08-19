{ lib, ... }:

{
  wayland.windowManager.hyprland.settings = {
    config.ecosystem.enforce_permissions = true;
    permission = lib.mkDefault [
      # Match the binary name regardless of the Nix store prefix
      {
        binary = "grim";
        type = "screencopy";
        mode = "allow";
      }
      {
        binary = "xdg-desktop-portal-hyprland";
        type = "screencopy";
        mode = "allow";
      }
      {
        binary = "hyprpm";
        type = "plugin";
        mode = "allow";
      }
    ];
  };
}
