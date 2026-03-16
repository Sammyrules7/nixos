{ config, lib, pkgs, ... }:

{
  options.features.audio.enable = lib.mkEnableOption "Audio configuration (Pipewire)";

  config = lib.mkIf config.features.audio.enable {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
