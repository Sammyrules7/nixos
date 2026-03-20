{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.features.gaming.steam.enable = lib.mkEnableOption "Steam and gaming enhancements";

  config = lib.mkIf config.features.gaming.steam.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extraPackages = with pkgs; [
        gamemode
        gamescope
      ];
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };
    programs.gamemode.enable = true;
  };
}
