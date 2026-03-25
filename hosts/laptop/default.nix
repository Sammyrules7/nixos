{ inputs, pkgs, ... }:

{
  imports = [
    ../common
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
  ];
  programs.gamescope = {
    enable = true;
    capSysNice = true; # Helps with smooth frame timing
  };
  features.gaming.steam.enable = true;
  features.fprintd.enable = true;
  features.power.enable = true;
  features.upgrade = {
    cpuThreads = 2;
    memoryHigh = "8G";
    memoryMax = "10G";
  };

  networking.hostName = "Sammy_Laptop";

  boot.kernelParams = [
    "amd_iommu=off"
    "amdgpu.fastboot=1"
  ];

  users.users.sammy.extraGroups = [
    "video"
    "iio"
  ];

  boot.initrd.kernelModules = [
    "tpm_crb"
  ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr
      libva
      libva-utils
      mesa
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      libva-vdpau-driver
    ];
  };

  environment.systemPackages = with pkgs; [
    brightnessctl
  ];

  boot.initrd.luks.devices."luks-9a6748f1-b660-4f2c-b9fe-40b0dd70c0d7" = {
    device = "/dev/disk/by-uuid/9a6748f1-b660-4f2c-b9fe-40b0dd70c0d7";
    crypttabExtraOpts = [ "tpm2-device=auto" ];
  };

  home-manager.users.sammy = {
    imports = [
      ./displays.nix
    ];
    features.btop.package = pkgs.btop.override { rocmSupport = true; };
    features.voxtype = {
      enable = true;
      model = "base.en";
    };
    features.theming = {
      enable = true;
      scaling = 1.0;
    };
    wayland.windowManager.hyprland.settings.input.sensitivity = 0.3;
  };
}
