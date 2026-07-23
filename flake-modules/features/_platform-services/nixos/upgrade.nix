{ config, lib, ... }:

{
  options.features.upgrade = {
    enable = lib.mkEnableOption "Auto-upgrade feature";
    cpuThreads = lib.mkOption {
      type = lib.types.int;
      default = 2;
      description = "Number of CPU threads to use for background builds.";
    };
    cpuQuota = lib.mkOption {
      type = lib.types.str;
      default = "25%";
      description = "CPU quota for the upgrade service.";
    };
    memoryHigh = lib.mkOption {
      type = lib.types.str;
      default = "2G";
      description = "Soft memory limit for the upgrade service.";
    };
    memoryMax = lib.mkOption {
      type = lib.types.str;
      default = "4G";
      description = "Hard memory limit for the upgrade service.";
    };
  };

  config = lib.mkIf config.features.upgrade.enable {
    system.autoUpgrade = {
      enable = true;
      operation = "switch";
      flake = "github:Sammyrules7/nixos";
      dates = "02:00";
      randomizedDelaySec = "45min";
      persistent = true;
      flags = [
        "--recreate-lock-file"
        "-L" # print build logs
      ];
    };

    systemd.services.nixos-upgrade = {
      unitConfig.ConditionACPower = true;
      serviceConfig = {
        Nice = 19;
        CPUSchedulingPolicy = "idle";
        IOSchedulingClass = "idle";
        CPUQuota = config.features.upgrade.cpuQuota;
        MemoryHigh = config.features.upgrade.memoryHigh;
        MemoryMax = config.features.upgrade.memoryMax;
      };
      environment = {
        NIX_BUILD_CORES = toString config.features.upgrade.cpuThreads;
      };
    };
  };
}
