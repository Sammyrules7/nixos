{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./autostart.nix
    ./binds.nix
    ./hyprshot.nix
    ./web-apps.nix
    ./waybar.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./input.nix
    ./permissions.nix
    ./pretty.nix
    ./sunset.nix
    ./windowrules.nix
  ];

  config = {
    features.hyprland.hypridle.enable = lib.mkDefault true;
    features.hyprland.hyprlock.enable = lib.mkDefault true;
    features.hyprland.hyprshot.enable = lib.mkDefault true;

    home.packages = with pkgs; [
      playerctl
      impala
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      configType = "hyprlang";
      settings = {
        general = {
          allow_tearing = true;
        };
        env = [
          "GDK_DPI_SCALE,${builtins.toString config.features.theming.scaling}"
          "QT_SCALE_FACTOR,${builtins.toString config.features.theming.scaling}"
          "QT_FONT_DPI,72"
        ];
      };
    };
  };
}
