{ config, lib, ... }:

{
  options.features.flatpak.enable = lib.mkEnableOption "Flatpak support";

  config = lib.mkIf config.features.flatpak.enable {
    services.flatpak.enable = true;
  };
}
