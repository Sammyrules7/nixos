{ config, lib, pkgs, ... }:

{
  options.features.core.enable = lib.mkEnableOption "Core system configuration";

  config = lib.mkIf config.features.core.enable {
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      substituters = [
        "https://cache.nixos.org/"
        "https://zen-browser.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "zen-browser.cachix.org-1:z/QLGrEkiBYF/7zoHX1Hpuv0B26QrmbVBSy9yDD2tSs="
      ];
    };

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    systemd.services.nix-gc.unitConfig.ConditionACPower = true;

    nixpkgs.config.allowUnfree = true;

    zramSwap = {
      enable = true;
      algorithm = "zstd";
    };

    time.timeZone = "America/Edmonton";
    i18n.defaultLocale = "en_CA.UTF-8";

    documentation.nixos.enable = false;

    system.stateVersion = "25.11";

    environment.systemPackages = with pkgs; [
      git
    ];
  };
}
