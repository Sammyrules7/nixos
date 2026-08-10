{
  config,
  lib,
  pkgs,
  ...
}:

let
  primaryUser = config.workstation.user;
  atticConfig = "${primaryUser.homeDirectory}/.config/attic/config.toml";
in
{
  environment.systemPackages = [ pkgs.attic-client ];

  systemd.services.attic-watch-store = {
    description = "Upload new Nix store paths to the main Attic cache";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [
      "network-online.target"
      "nix-daemon.service"
    ];

    environment = {
      HOME = primaryUser.homeDirectory;
      XDG_CONFIG_HOME = "${primaryUser.homeDirectory}/.config";
    };

    unitConfig = {
      ConditionPathExists = atticConfig;
      StartLimitIntervalSec = "5m";
      StartLimitBurst = 3;
    };

    serviceConfig = {
      User = primaryUser.name;
      Group = "users";
      ExecStart = "${lib.getExe pkgs.attic-client} watch-store --jobs 2 main";
      Restart = "on-failure";
      RestartSec = "30s";

      Nice = 10;
      IOSchedulingClass = "idle";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = "read-only";
      ProtectSystem = "strict";
    };
  };
}
