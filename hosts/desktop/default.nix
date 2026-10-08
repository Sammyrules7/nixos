{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.interfaces.enp4s0.wakeOnLan.enable = true;
  services.tailscale.extraSetFlags = [ "--hostname=sammydesktop" ];

  # This laptop's current network drops full-size tunnel replies. Keep the
  # smaller MTU local to this peer rather than changing the entire tailnet.
  systemd.services.game-stream-route = {
    description = "Conservative Tailscale route to the streaming laptop";
    after = [ "tailscaled.service" ];
    wants = [ "tailscaled.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      if ${pkgs.iproute2}/bin/ip route show table 52 100.78.86.94/32 | ${pkgs.gnugrep}/bin/grep -q tailscale0; then
        ${pkgs.iproute2}/bin/ip route change 100.78.86.94/32 dev tailscale0 table 52 mtu 1200 advmss 1100
      fi
    '';
  };
  systemd.timers.game-stream-route = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "10s";
      OnUnitActiveSec = "30s";
    };
  };

  features.gaming.vr.enable = true;
  features.sunshine = {
    enable = true;
    encoder = "nvenc";
  };
  features.openclaw-node = {
    enable = true;
    fullAccess = true;
  };
  features.ollama.enable = true;
  features.upgrade = {
    cpuThreads = 5;
    memoryHigh = "24G";
    memoryMax = "32G";
  };

  networking.hostName = "Sammy_Desktop";

  boot.initrd.luks.devices."luks-c30766d4-738f-4fa0-9570-a026696d128a" = {
    device = "/dev/disk/by-uuid/c30766d4-738f-4fa0-9570-a026696d128a";
    crypttabExtraOpts = [ "tpm2-device=auto" ];
  };

  boot.initrd.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];

  boot.kernel.sysctl."vm.swappiness" = 150;

  # Hardware-specific (if any, e.g. for NVIDIA)
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;

  features.power = {
    enable = true;
    mode = "minimal";
  };

  home-manager.users.${config.workstation.user.name} = {
    imports = [
      ./displays.nix
    ];
    features.btop.package = pkgs.btop.override { cudaSupport = true; };
    features.voxtype = {
      enable = true;
      model = "small.en";
    };
    features.theming = {
      scaling = 0.8;
    };
    features.hyprland.hypridle = {
      enable = true;
      lockOnly = true;
    };
    wayland.windowManager.hyprland.settings.config.input.sensitivity = 0;
  };
}
