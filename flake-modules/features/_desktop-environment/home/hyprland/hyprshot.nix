{
  config,
  lib,
  pkgs,
  ...
}:

let
  lua = import ./lua.nix { inherit lib; };
  exec = command: lua.dispatcher "exec_cmd" command;
in
{
  options.features.hyprland.hyprshot.enable = lib.mkEnableOption "Hyprshot screenshot tool";

  config = lib.mkIf config.features.hyprland.hyprshot.enable {
    home.packages = with pkgs; [
      hyprshot
    ];

    wayland.windowManager.hyprland.settings = {
      permission = [
        {
          binary = lib.getExe pkgs.hyprshot;
          type = "screencopy";
          mode = "allow";
        }
        {
          binary = lib.getExe pkgs.hyprpicker;
          type = "screencopy";
          mode = "allow";
        }
        {
          binary = lib.getExe pkgs.grim;
          type = "screencopy";
          mode = "allow";
        }
      ];

      bind = [
        (lua.bind "CONTROL + PRINT" (exec "hyprshot -m output -m active --clipboard-only"))
        (lua.bind "CONTROL + SHIFT + PRINT" (exec "hyprshot -m region -z --clipboard-only"))
        (lua.bind "CONTROL + ALT + PRINT" (exec "hyprshot -m window -m active --clipboard-only"))
      ];
    };
  };
}
