{ ... }:

{
  imports = [
    ../common
    ./hardware-configuration.nix
  ];

  networking.hostName = "Sammy_Laptop";

  boot.initrd.kernelModules = [ "tpm_crb" "amdgpu" ];
  boot.kernelParams = [ "amdgpu.fastboot=1" ];

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
