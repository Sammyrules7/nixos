{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.features.mako.enable = lib.mkEnableOption "Mako notification daemon";

  config = lib.mkIf config.features.mako.enable {
    services.mako = {
      enable = true;

      settings = {
        background-color = lib.mkForce "#00000003";

        border-radius = 12;
        border-size = 0;

        font = lib.mkForce "JetBrainsMono Nerd Font Mono 11";
        width = 350;
        height = 150;
        padding = "15";
        margin = "15";

        default-timeout = 5000;
      };

      extraConfig = ''
        [mode=do-not-disturb]
        invisible=1
      '';
    };

    systemd.user.services.mako = {
      Unit = {
        Description = "Mako notification daemon";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
