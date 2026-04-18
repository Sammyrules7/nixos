{ config, lib, ... }:

{
  options.features.tailscale.enable = lib.mkEnableOption "Tailscale VPN";

  config = lib.mkIf config.features.tailscale.enable {
    services.tailscale.enable = true;
  };
}