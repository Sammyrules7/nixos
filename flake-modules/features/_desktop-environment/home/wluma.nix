{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.features.wluma = {
    enable = lib.mkEnableOption "wluma automatic brightness adjustment";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.wluma;
      description = "wluma package to use";
    };
  };

  config = lib.mkIf config.features.wluma.enable {
    services.wluma = {
      enable = true;
      package = config.features.wluma.package;
    };
    wayland.windowManager.hyprland.settings = {
      permission = [
        "${pkgs.wluma}/bin/.wluma-wrapped, screencopy, allow"
      ];
      bind = [
        "$mod, XF86MonBrightnessDown, exec, sh -c 'if systemctl --user is-active --quiet wluma.service; then systemctl --user stop wluma.service; swayosd-client --custom-message \"Auto Brightness Disabled\" --custom-icon \"display-brightness-symbolic\"; fi'"
        "$mod, XF86MonBrightnessUp, exec, sh -c 'if ! systemctl --user is-active --quiet wluma.service; then systemctl --user start wluma.service; swayosd-client --custom-message \"Auto Brightness Enabled\" --custom-icon \"display-brightness-symbolic\"; fi'"
      ];
    };
    home.file.".config/wluma/config.toml".text = ''
      [als.iio]
      path = "/sys/bus/iio/devices/"
      thresholds = { 0 = "night", 20 = "dark", 80 = "dim", 250 = "normal", 500 = "bright", 800 = "outdoors" }

      [[output.backlight]]
      name = "eDP-1"
      path = "/sys/class/backlight/amdgpu_bl1"
      capturer = "wayland"
    '';
  };
}
