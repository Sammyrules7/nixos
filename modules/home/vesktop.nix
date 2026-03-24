{ config, lib, ... }:

{
  options.features.vesktop.enable = lib.mkEnableOption "vesktop configuration";

  config = lib.mkIf config.features.vesktop.enable {
    # Disable Stylix's automatic Vesktop theming to prevent it from overriding our config
    stylix.targets.vesktop.enable = false;

    programs.vesktop = {
      enable = lib.mkForce true;
      # Use mkForce to ensure our settings take precedence over any defaults or other modules
      settings = lib.mkForce {
        discordBranch = "stable";
        minimizeToTray = true;
        arRPC = true;
        splashColor = "rgb(220, 220, 223)";
        splashBackground = "rgb(0, 0, 0)";
        hardwareAcceleration = true;
        hardwareVideoAcceleration = true;
        disableSmoothScroll = false;
        transparent = true;
        electronTranslucency = true;
        vibrancy = true;
        vibrancyType = "blur";
        opacity = 0.95;
      };
      vencord = {
        themes = {
          "translucence" = ''
            /**
             * @name Translucence
             * @author CapnKitten
             * @description A translucent theme for BetterDiscord/Vencord.
             * @source https://github.com/CapnKitten/BetterDiscord/tree/master/Themes/Translucence
            */

            @import url("https://capnkitten.github.io/BetterDiscord/Themes/Translucence/css/source.css");

            :root {
              --translucence-brightness: 100%;
              --translucence-contrast: 100%;
              --translucence-saturation: 100%;
              --app-bg: 0,0,0,0;
              --translucence-blur: 0px;
            }
          '';
        };
        settings = lib.mkForce {
          enabledThemes = [ "translucence.css" ];
          useQuickCss = true;
          transparent = true;
          frameless = true;
        };
      };
    };
  };
}
