{ config, lib, ... }:

{
  options.features.flatpak.enable = lib.mkEnableOption "Flatpak support";

  config = lib.mkIf config.features.flatpak.enable {
    services.flatpak = {
      enable = true;
      update.auto = {
        enable = true;
        onCalendar = "daily";
      };
      remotes = lib.mkOptionDefault [
        {
          name = "flathub";
          location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }
      ];
      packages = [
        "org.pipewire.Helvum"
        "org.vinegarhq.Sober"
      ];
      overrides = {
        "org.vinegarhq.Sober" = {
          Context = {
            filesystems = [
              "xdg-run/app/com.discordapp.Discord:create"
              "xdg-run/discord-ipc-0"
            ];
          };
        };
      };
    };
    systemd.services.flatpak-managed-install-timer = {
      unitConfig.ConditionACPower = true;
      serviceConfig = {
        Nice = 19;
        CPUSchedulingPolicy = "idle";
        IOSchedulingClass = "idle";
        CPUQuota = config.features.upgrade.cpuQuota;
        MemoryHigh = config.features.upgrade.memoryHigh;
        MemoryMax = config.features.upgrade.memoryMax;
      };
    };
  };
}
