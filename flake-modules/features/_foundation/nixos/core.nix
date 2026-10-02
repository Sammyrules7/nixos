{ lib, ... }:

{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    # Hashing every imported file competes with interactive work for disk I/O.
    auto-optimise-store = false;
    substituters = [
      "https://cache.nixos.org/"
      "https://attic.maio-tech.com/main"
      "https://zen-browser.cachix.org"
      "https://walker.cachix.org"
      "https://walker-git.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "main:arW6XEJpG5vVm3SeAKZ4gohKH6xAKRN2E02iz6vgbXE="
      "zen-browser.cachix.org-1:z/QLGrEkiBYF/7zoHX1Hpuv0B26QrmbVBSy9yDD2tSs="
      "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
      "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  systemd.services.nix-gc = {
    unitConfig.ConditionACPower = true;
    serviceConfig = {
      Nice = 19;
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
      IOWeight = 1;
      IOReadBandwidthMax = "/nix 10M";
      IOWriteBandwidthMax = "/nix 5M";
      IOReadIOPSMax = "/nix 100";
      IOWriteIOPSMax = "/nix 50";
      CPUQuota = "25%";
      MemoryHigh = "512M";
      MemoryMax = "1G";
    };
  };

  nix.optimise = {
    automatic = true;
    dates = [ "Sun 04:00" ];
  };
  systemd.services.nix-optimise = {
    unitConfig.ConditionACPower = true;
    # Prefer GC first when both maintenance units are queued together.
    after = [ "nix-gc.service" ];
    serviceConfig = {
      Nice = 19;
      IOSchedulingClass = "idle";
      IOWeight = 1;
      IOReadBandwidthMax = "/nix 10M";
      IOWriteBandwidthMax = "/nix 5M";
      IOReadIOPSMax = "/nix 100";
      IOWriteIOPSMax = "/nix 50";
      CPUQuota = "25%";
      MemoryHigh = "512M";
      MemoryMax = "1G";
    };
  };
  systemd.timers.nix-optimise.timerConfig = {
    Persistent = lib.mkForce false;
    RandomizedDelaySec = lib.mkForce "30m";
  };
  systemd.timers.nix-gc.timerConfig = {
    OnCalendar = lib.mkForce [ ];
    OnBootSec = "1h";
    OnUnitActiveSec = "1w";
    Persistent = lib.mkForce false;
    RandomizedDelaySec = lib.mkForce "15m";
  };

  nixpkgs.config.allowUnfree = true;

  programs.nix-ld.enable = true;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 200;
  };

  time.timeZone = "America/Edmonton";
  i18n.defaultLocale = "en_CA.UTF-8";

  documentation.nixos.enable = false;

  system.stateVersion = "25.11";
}
