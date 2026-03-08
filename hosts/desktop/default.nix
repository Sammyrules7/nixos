{ ... }:

{
  imports = [
    ../common
    ./hardware-configuration.nix
  ];

  networking.hostName = "Sammy_Desktop";

  boot.initrd.luks.devices."luks-c30766d4-738f-4fa0-9570-a026696d128a" = {
    device = "/dev/disk/by-uuid/c30766d4-738f-4fa0-9570-a026696d128a";
    crypttabExtraOpts = [ "tpm2-device=auto" ];
  };

  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];

  # Hardware-specific (if any, e.g. for NVIDIA)
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;

  home-manager.users.sammy = {
    imports = [
      ./displays.nix
    ];
    wayland.windowManager.hyprland.settings.input.sensitivity = 0;
  };
}
