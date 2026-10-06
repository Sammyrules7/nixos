{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.features.ollama = {
    enable = lib.mkEnableOption "Ollama local LLM service";
    acceleration = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "cuda"
          "rocm"
        ]
      );
      default = null;
      description = "Hardware acceleration for Ollama";
    };
    onlyOnAC = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Only run Ollama when connected to AC power";
    };
    enableIntegratedGPU = lib.mkEnableOption "integrated GPU inference in Ollama";
    models = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "qwen2.5-coder:7b"
        "qwen2.5-coder:1.5b"
      ];
      description = "List of models to pre-pull";
    };
  };

  config = lib.mkIf config.features.ollama.enable {
    services.ollama = {
      enable = true;
      package =
        if config.features.ollama.acceleration == "cuda" then
          pkgs.ollama-cuda
        else if config.features.ollama.acceleration == "rocm" then
          pkgs.ollama-rocm
        else
          pkgs.ollama;

      # ROCm support for AMD GPUs
      rocmOverrideGfx = lib.mkIf (config.features.ollama.acceleration == "rocm") "11.0.2"; # Phoenix (7040 series)

      loadModels = config.features.ollama.models;
      environmentVariables = lib.mkIf config.features.ollama.enableIntegratedGPU {
        OLLAMA_IGPU_ENABLE = "1";
      };
    };

    systemd.services.ollama = {
      unitConfig = lib.mkIf config.features.ollama.onlyOnAC {
        ConditionACPower = true;
      };
    };

    # NetworkManager's online target can be reached before DNS is usable.
    # Keep the loader retrying without repeatedly hammering the registry at boot.
    systemd.services.ollama-model-loader.serviceConfig =
      lib.mkIf (config.features.ollama.models != [ ])
        {
          RestartSec = lib.mkForce "30s";
          RestartMaxDelaySec = lib.mkForce "15min";
        };

    systemd.services.ollama-ac-power = lib.mkIf config.features.ollama.onlyOnAC {
      description = "Reconcile Ollama with stable AC power state";
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-udev-trigger.service" ];
      path = [
        pkgs.coreutils
        pkgs.systemd
      ];
      serviceConfig = {
        Type = "oneshot";
        TimeoutStartSec = "15s";
      };
      script = ''
        # Coalesce charging notifications and check the current aggregate state.
        sleep 2
        on_ac=false
        for supply in /sys/class/power_supply/*; do
          [[ -f "$supply/type" && -f "$supply/online" ]] || continue
          if [[ $(cat "$supply/type") == Mains && $(cat "$supply/online") == 1 ]]; then
            on_ac=true
            break
          fi
        done
        if "$on_ac"; then
          systemctl --no-block start ollama.service
        else
          systemctl --no-block stop ollama.service
        fi
      '';
    };

    # Stop/Start Ollama based on AC power status
    services.udev.extraRules = lib.mkIf config.features.ollama.onlyOnAC ''
      ACTION=="add|change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", RUN+="${pkgs.systemd}/bin/systemctl --no-block start ollama-ac-power.service"
    '';
  };
}
