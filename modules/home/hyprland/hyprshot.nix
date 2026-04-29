{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.features.hyprland.hyprshot.enable = lib.mkEnableOption "Hyprshot screenshot tool";

  config = lib.mkIf config.features.hyprland.hyprshot.enable {
    home.packages = with pkgs; [
      hyprshot
    ];

    wayland.windowManager.hyprland.settings = {
      permission = [
        "${lib.getExe pkgs.hyprshot}, screencopy, allow"
        "${lib.getExe pkgs.hyprpicker}, screencopy, allow"
        "${lib.getExe pkgs.grim}, screencopy, allow"
      ];

      bind = [
        "CONTROL, PRINT, exec, hyprshot -m output -m active --clipboard-only"
        "CONTROL SHIFT, PRINT, exec, hyprshot -m region -z --clipboard-only"
        "CONTROL_ALT, PRINT, exec, hyprshot -m window -m active -z --clipboard-only"
      ];
    };
  };
}
