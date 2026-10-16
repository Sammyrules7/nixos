{ config, pkgs, ... }:

{
  services.tailscale.enable = true;

  # Peer networks on this tailnet drop full-size tunnel packets: desktop ->
  # laptop replies stall SSH bulk traffic and post-quantum KEX exchanges, and
  # the game-stream route already needs mtu 1200 to work. Clamp tailscale0 on
  # every workstation so every peer path is bounded, not just the one IPv4
  # route worked around in hosts/desktop/default.nix. Timer re-asserts it in
  # case tailscaled recreates the interface.
  systemd.services.tailscale-mtu = {
    description = "Clamp tailscale0 tunnel MTU to 1200";
    after = [ "tailscaled.service" ];
    wants = [ "tailscaled.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.iproute2}/bin/ip link set tailscale0 mtu 1200";
    };
  };
  systemd.timers.tailscale-mtu = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "10s";
      OnUnitActiveSec = "30s";
    };
  };
}
