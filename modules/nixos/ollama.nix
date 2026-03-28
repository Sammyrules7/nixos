{ config, lib, pkgs, ... }:

{
  options.features.ollama = {
    enable = lib.mkEnableOption "Ollama local LLM service";
    acceleration = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "cuda" "rocm" ]);
      default = null;
      description = "Hardware acceleration for Ollama";
    };
    onlyOnAC = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Only run Ollama when connected to AC power";
    };
    models = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "qwen2.5-coder:7b" "qwen2.5-coder:1.5b" ];
      description = "List of models to pre-pull";
    };
  };

  config = lib.mkIf config.features.ollama.enable {
    services.ollama = {
      enable = true;
      package = if config.features.ollama.acceleration == "cuda" then
        pkgs.ollama-cuda
      else if config.features.ollama.acceleration == "rocm" then
        pkgs.ollama-rocm
      else
        pkgs.ollama;
      
      # ROCm support for AMD GPUs
      rocmOverrideGfx = lib.mkIf (config.features.ollama.acceleration == "rocm") "11.0.2"; # Phoenix (7040 series)
      
      loadModels = config.features.ollama.models;
    };

    systemd.services.ollama = {
      serviceConfig = lib.mkIf config.features.ollama.onlyOnAC {
        ConditionACPower = true;
      };
    };

    # Stop/Start Ollama based on AC power status
    services.udev.extraRules = lib.mkIf config.features.ollama.onlyOnAC ''
      SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="${pkgs.systemd}/bin/systemctl stop ollama.service"
      SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${pkgs.systemd}/bin/systemctl start ollama.service"
    '';
  };
}
