{ config, lib, ... }:

{
  options.features.vesktop.enable = lib.mkEnableOption "vesktop configuration";

  config = lib.mkIf config.features.vesktop.enable {
    programs.vesktop = {
      enable = true;
      settings = {
        "discordBranch" = "stable";
        "minimizeToTray" = true;
        "arRPC" = true;
        "splashColor" = "rgb(220, 220, 223)";
        "splashBackground" = "rgb(0, 0, 0)";
        "hardwareVideoAcceleration" = false;
        "disableSmoothScroll" = false;
      };
      vencord = { };
    };
  };
}
