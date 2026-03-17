{ inputs, pkgs, ... }:

{
  imports = [
    ../common
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
  ];

  features.fprintd.enable = true;

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
    "amdgpu"
  ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      rocmPackages.clr
    ];
  };

  environment.systemPackages = with pkgs; [
    (btop.override { rocmSupport = true; })
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
    features.voxtype = {
      enable = true;
      model = "base.en";
    };
    wayland.windowManager.hyprland.settings.input.sensitivity = 0.3;
  };
}
