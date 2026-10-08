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

    fullAccess = lib.mkEnableOption "unprompted main-agent execution with normal user filesystem access";

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
      unitConfig = {
        ConditionPathExists = config.sops.secrets.openclaw-gateway-token.path;
        StartLimitIntervalSec = "5m";
        StartLimitBurst = 3;
      };
      after = [
        "network-online.target"
        "sops-nix.service"
      ];

      environment = {
        OPENCLAW_STATE_DIR = "/var/lib/openclaw";
        PATH = lib.mkForce "/run/current-system/sw/bin:/etc/profiles/per-user/${primaryUser.name}/bin";
      };

      # Runtime config and host approvals are independent node policy gates.
      # Disabling fullAccess resets main to a conservative policy, rather than
      # restoring its previous manually configured policy. Other agents remain.
      preStart = ''
        set -eu
        umask 077
        configError="$(${pkgs.coreutils}/bin/mktemp "$OPENCLAW_STATE_DIR/.config-error.XXXXXX")"
        trap '${pkgs.coreutils}/bin/rm -f "$configError"' EXIT
        if ! agents="$(${lib.getExe pkgs.openclaw} config get agents.list --json 2>"$configError")"; then
          if ${pkgs.gnugrep}/bin/grep -Fq 'Config path not found: agents.list.' "$configError"; then
            agents='[]'
          else
            echo "Unable to read node agent config; refusing to overwrite it" >&2
            exit 1
          fi
        fi
        index="$(printf '%s' "$agents" | ${pkgs.jq}/bin/jq -er '
          if type != "array" then error("Unsupported agents list") else
            [to_entries[] | select((.value.id | ascii_downcase) == "main") | .key] |
            if length > 1 then error("Duplicate main agents") else .[0] // empty end
          end
        ')" || {
          index="$(printf '%s' "$agents" | ${pkgs.jq}/bin/jq -er '
            if type == "array" and all(.[]; (.id | type) == "string" and (.id | ascii_downcase) != "main")
            then length else error("Invalid agents list") end
          ')"
          ${lib.getExe pkgs.openclaw} config set "agents.list[$index].id" '"main"' --strict-json
        }
        execPolicy="$(printf '%s' "$agents" | ${pkgs.jq}/bin/jq -c --argjson index "$index" '
          (.[ $index ].tools.exec // {}) | del(.mode) + {
            security: "${if cfg.fullAccess then "full" else "allowlist"}",
            ask: "${if cfg.fullAccess then "off" else "on-miss"}"
          }
        ')"
        ${lib.getExe pkgs.openclaw} config set "agents.list[$index].tools.exec" "$execPolicy" --strict-json
        ${pkgs.coreutils}/bin/rm -f "$configError"

        # Preserve socket metadata, defaults, other agents, and allowlists.
        approvals="$OPENCLAW_STATE_DIR/exec-approvals.json"
        if [ -L "$approvals" ]; then
          echo "Refusing symlinked exec approvals" >&2
          exit 1
        fi
        tmp="$(${pkgs.coreutils}/bin/mktemp "$OPENCLAW_STATE_DIR/.exec-approvals.XXXXXX")"
        trap '${pkgs.coreutils}/bin/rm -f "$tmp"' EXIT
        if [ -e "$approvals" ]; then
          ${pkgs.jq}/bin/jq -e '
            if .version == 1 and (.agents == null or (.agents | type) == "object") then
              .agents.main = ((.agents.main // {}) + {
                security: "${if cfg.fullAccess then "full" else "allowlist"}",
                ask: "${if cfg.fullAccess then "off" else "on-miss"}", askFallback: "deny"
              })
            else error("Unsupported exec approvals schema") end
          ' "$approvals" > "$tmp"
        else
          ${pkgs.jq}/bin/jq -n '{version: 1, agents: {main: {
            security: "${if cfg.fullAccess then "full" else "allowlist"}",
            ask: "${if cfg.fullAccess then "off" else "on-miss"}", askFallback: "deny"
          }}}' > "$tmp"
        fi
        ${pkgs.coreutils}/bin/chmod 0600 "$tmp"
        ${pkgs.coreutils}/bin/mv -f "$tmp" "$approvals"
      '';

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
        # Allow the node user to write anywhere normal Unix permissions allow.
        # Keep NoNewPrivileges: no privilege escalation/root grant is intended.
        ProtectSystem = if cfg.fullAccess then false else "strict";
        ReadWritePaths = lib.mkIf (!cfg.fullAccess) [ "/var/lib/openclaw" ];
      };
    };
  };
}
