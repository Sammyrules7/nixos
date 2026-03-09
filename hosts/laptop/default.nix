{ inputs, pkgs, ... }:

{
  imports = [
    ../common
    ./hardware-configuration.nix
    ./fprintd.nix
    ../../modules/services/wluma.nix
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
  ];

  networking.hostName = "Sammy_Laptop";

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
  ];

  boot.initrd.luks.devices."luks-9a6748f1-b660-4f2c-b9fe-40b0dd70c0d7" = {
    device = "/dev/disk/by-uuid/9a6748f1-b660-4f2c-b9fe-40b0dd70c0d7";
    crypttabExtraOpts = [ "tpm2-device=auto" ];
  };

  home-manager.users.sammy = {
    imports = [
      ./displays.nix
    ];
    wayland.windowManager.hyprland.settings.input.sensitivity = 0.3;
  };
}
