{ config, lib, pkgs, ... }:

{
  options.features.hyprland.enable = lib.mkEnableOption "Hyprland desktop environment";

  config = lib.mkIf config.features.hyprland.enable {
    programs.hyprland.enable = true;
    security.pam.services.hyprlock = {};

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd 'start-hyprland' --sessions /run/current-system/sw/share/wayland-sessions";
          user = "greeter";
        };
      };
    };
  };
}
