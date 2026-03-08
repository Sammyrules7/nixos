{ config, pkgs, inputs, ... }:

{
  imports = [
    ../common
    ./hardware-configuration.nix
  ];

  networking.hostName = "Sammy_Desktop";

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
