{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.openclaw-node;
  primaryUser = config.workstation.user;
  serviceName = "openclaw-node.service";
in
{
  options.features.openclaw-node = {
    enable = lib.mkEnableOption "the OpenClaw headless node";

    gatewayHost = lib.mkOption {
      type = lib.types.str;
      default = "sammy-openclaw.maio-tech.com";
      description = "OpenClaw gateway WebSocket hostname.";
    };

    gatewayPort = lib.mkOption {
      type = lib.types.port;
      default = 443;
      description = "OpenClaw gateway WebSocket port.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Nixpkgs marks OpenClaw insecure because agents can act on
    # prompt-injected content with the permissions granted to this node.
    nixpkgs.config.permittedInsecurePackages = [
      "openclaw-${pkgs.openclaw.version}"
    ];

    environment.systemPackages = [ pkgs.openclaw ];

    sops.secrets.openclaw-gateway-token = {
      sopsFile = ./openclaw.enc.yaml;
      key = "gateway_token";
      owner = primaryUser.name;
      mode = "0400";
      restartUnits = [ serviceName ];
    };

    systemd.services.openclaw-node = {
      description = "OpenClaw headless node";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [
        "network-online.target"
        "sops-nix.service"
      ];

      environment = {
        OPENCLAW_STATE_DIR = "/var/lib/openclaw";
        PATH = lib.mkForce "/run/current-system/sw/bin:/etc/profiles/per-user/${primaryUser.name}/bin";
      };

      script = ''
        export OPENCLAW_GATEWAY_TOKEN="$(
          < "$CREDENTIALS_DIRECTORY/gateway-token"
        )"

        exec ${lib.getExe pkgs.openclaw} node run \
          --host ${lib.escapeShellArg cfg.gatewayHost} \
          --port ${toString cfg.gatewayPort} \
          --tls \
          --display-name "$HOSTNAME"
      '';

      serviceConfig = {
        User = primaryUser.name;
        Group = "users";
        StateDirectory = "openclaw";
        StateDirectoryMode = "0700";
        LoadCredential = "gateway-token:${config.sops.secrets.openclaw-gateway-token.path}";
        Restart = "on-failure";
        RestartSec = "5s";

        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ReadWritePaths = [ "/var/lib/openclaw" ];
      };
    };
  };
}
