{ ... }:

{
  imports = [
    ../common
    ./hardware-configuration.nix
  ];

  features.gaming.steam.enable = true;
  features.gaming.vr.enable = true;
  features.upgrade = {
    cpuThreads = 5;
    memoryHigh = "16G";
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

  zramSwap.memoryPercent = 75;

  # Hardware-specific (if any, e.g. for NVIDIA)
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;

  home-manager.users.sammy = {
    imports = [
      ./displays.nix
    ];
    features.voxtype = {
      enable = true;
      model = "small.en";
    };
    wayland.windowManager.hyprland.settings.input.sensitivity = 0;
  };
}
