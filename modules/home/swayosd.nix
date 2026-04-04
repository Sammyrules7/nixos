{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.features.swayosd.enable = lib.mkEnableOption "SwayOSD daemon and configuration";

  config = lib.mkIf config.features.swayosd.enable {
    home.packages = [
      pkgs.swayosd
      pkgs.adwaita-icon-theme
    ];

    systemd.user.services.swayosd = {
      Unit = {
        Description = "SwayOSD daemon";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.swayosd}/bin/swayosd-server";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    xdg.configFile."swayosd/style.css".text = ''
      window#osd {
        background-color: transparent;
      }

      #container {
        background-color: rgba(26, 27, 38, 0.004);
        border-radius: 20px;
        padding: 20px;
      }

      progressbar,
      trough {
        border-radius: 999px;
        min-height: 10px;
        background-color: rgba(255, 255, 255, 0.05);
      }

      progress {
        background-color: #ffffff;
      }

      label {
        font-size: 18px;
        font-weight: 500;
        color: #ffffff;
        margin-left: 12px;
      }

      image {
        color: #ffffff;
        min-width: 44px;
        min-height: 44px;
      }
    '';

  };
}
