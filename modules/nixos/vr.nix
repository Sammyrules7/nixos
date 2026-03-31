{ config, lib, pkgs, ... }:

{
  options.features.gaming.vr.enable = lib.mkEnableOption "VR support (Monado, WiVRn, Xrizer)";

  config = lib.mkIf config.features.gaming.vr.enable {
    nixpkgs.config.cudaSupport = true;
    nix.settings = {
      substituters = [
        "https://cache.nixos-cuda.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    services.monado = {
      enable = true;
      defaultRuntime = false;
    };

    services.wivrn = {
      enable = true;
      openFirewall = true;
      highPriority = true;
      package = (pkgs.wivrn.override { cudaSupport = true; });
    };

    environment.systemPackages = with pkgs; [
      xrizer
      wivrn
      wayvr
      vrcx
    ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
        libvdpau-va-gl
      ];
    };

    environment.sessionVariables = {
      LD_LIBRARY_PATH = [ "/run/opengl-driver/lib" ];
    };
  };
}
