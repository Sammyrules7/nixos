{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.voxtype;
  lua = import ../../_desktop-environment/home/hyprland/lua.nix { inherit lib; };
  exec = command: lua.dispatcher "exec_cmd" command;
in
{
  options.features.voxtype = {
    enable = lib.mkEnableOption "Voxtype voice-to-text with push-to-talk";
    vulkan = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use Vulkan-accelerated Voxtype";
    };
    model = lib.mkOption {
      type = lib.types.str;
      default = "base.en";
      description = "Whisper model to use";
    };
    engine = lib.mkOption {
      type = lib.types.str;
      default = "whisper";
      description = "Inference engine to use";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (if cfg.vulkan then pkgs.voxtype-vulkan else pkgs.voxtype)
      pkgs.wtype
    ];

    systemd.user.services.voxtype = {
      Unit = {
        Description = "Voxtype voice-to-text daemon";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${
          if cfg.vulkan then pkgs.voxtype-vulkan else pkgs.voxtype
        }/bin/voxtype  --model ${cfg.model} --engine ${cfg.engine} daemon";
        Restart = "on-failure";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    wayland.windowManager.hyprland.settings = {
      bind = [
        (lua.bind "SUPER + X" (exec "voxtype record start"))
        (lua.bindWith "SUPER + X" (exec "voxtype record stop") { release = true; })
      ];
    };
  };
}
