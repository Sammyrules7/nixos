{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.sunshine;
  user = config.workstation.user.name;
  sway = lib.getExe' pkgs.sway-unwrapped "sway";
  swaymsg = lib.getExe' pkgs.sway-unwrapped "swaymsg";

  # Run inside Sway, so these are this compositor's actual sockets, not the
  # physical desktop's environment imported into the shared user manager.
  ready = pkgs.writeShellScript "game-stream-ready" ''
    set -eu
    umask 077
    printf 'WAYLAND_DISPLAY=%s\nDISPLAY=%s\nSWAYSOCK=%s\n' \
      "$WAYLAND_DISPLAY" "$DISPLAY" "$SWAYSOCK" \
      > "$XDG_RUNTIME_DIR/game-stream/session.env"
    ${pkgs.systemd}/bin/systemd-notify --ready
  '';

  swayConfig = pkgs.writeText "game-stream-sway.conf" ''
    xwayland force
    output HEADLESS-1 mode 1920x1080@60Hz
    output * bg #181818 solid_color
    default_border none
    for_window [all] fullscreen enable

    # Only streamed input reaches this session; physical input stays local.
    input * events disabled
    input "48879:57005:Keyboard_passthrough" events enabled
    input "48879:57005:Mouse_passthrough" events enabled
    input "48879:57005:Mouse_passthrough_(absolute)" events enabled
    input "48879:57005:Touch_passthrough" events enabled
    input "48879:57005:Pen_passthrough" events enabled
    input "1356:3302:Sunshine_PS5_(virtual)_pad_Touchpad" events enabled
    input "48879:57005:Mouse_passthrough" accel_profile flat
    input "48879:57005:Mouse_passthrough_(absolute)" accel_profile flat

    exec ${ready}
  '';

  startSession = pkgs.writeShellScript "game-stream-session" ''
    unset DISPLAY WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE
    exec ${sway} --unsupported-gpu --config ${swayConfig}
  '';

  resize = pkgs.writeShellApplication {
    name = "game-stream-resize";
    text = ''
      width="''${SUNSHINE_CLIENT_WIDTH:-1920}"
      height="''${SUNSHINE_CLIENT_HEIGHT:-1080}"
      fps="''${SUNSHINE_CLIENT_FPS:-60}"
      for value in "$width" "$height" "$fps"; do
        if [[ ! "$value" =~ ^[1-9][0-9]{0,3}$ ]]; then
          echo "Invalid Moonlight display mode" >&2
          exit 1
        fi
      done
      ${swaymsg} "output HEADLESS-1 mode --custom ''${width}x''${height}@''${fps}Hz"
    '';
  };

  prep = [ { do = lib.getExe resize; } ];
  steamPrep = prep ++ [
    {
      do = "${pkgs.systemd}/bin/systemctl --user start game-stream-steam.service";
      undo = "${pkgs.systemd}/bin/systemctl --user stop game-stream-steam.service";
    }
  ];

  checkSteam = pkgs.writeShellScript "game-stream-check-steam" ''
    if ${pkgs.procps}/bin/pgrep -u "$(${pkgs.coreutils}/bin/id -u)" -x steam > /dev/null; then
      echo "Steam is already running locally. Exit Steam, including its tray icon, before streaming." >&2
      exit 1
    fi
  '';

  sessionEnvironment = {
    SHELL = lib.getExe pkgs.bash;
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "sway";
    PULSE_SINK = "game-stream";
  };
in
{
  options.features.sunshine = {
    enable = lib.mkEnableOption "headless Wayland game streaming with Sunshine";
    encoder = lib.mkOption {
      type = lib.types.enum [
        "nvenc"
        "vaapi"
        "software"
      ];
      default = "vaapi";
      description = "Streaming encoder; nvenc enables the CUDA Sunshine build for NVIDIA.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.sunshine = {
      enable = true;
      autoStart = false;
      openFirewall = false;
      capSysAdmin = false;
      package =
        if cfg.encoder == "nvenc" then pkgs.sunshine.override { cudaSupport = true; } else pkgs.sunshine;
      settings = {
        sunshine_name = "${config.networking.hostName} Gaming";
        capture = "wlr";
        encoder = cfg.encoder;
        # HEVC is the best codec this RTX 3060 Ti can encode. Avoid advertising
        # HDR from this SDR headless session or falling back to software AV1.
        hevc_mode = 2;
        av1_mode = 1;
        nvenc_preset = 1;
        nvenc_twopass = "quarter_res";
        output_name = "HEADLESS-1";
        audio_sink = "game-stream";
        upnp = "disabled";
        origin_web_ui_allowed = "pc";
      };
      applications.apps = [
        {
          name = "Steam Big Picture";
          prep-cmd = steamPrep;
          detached = [ "${lib.getExe config.programs.steam.package} steam://open/bigpicture" ];
        }
        {
          name = "Satisfactory";
          prep-cmd = steamPrep;
          detached = [ "${lib.getExe config.programs.steam.package} steam://rungameid/526870" ];
        }
        {
          name = "Desktop";
          prep-cmd = prep;
        }
      ];
    };

    # Streaming is reachable on the private tailnet. Keep the administration
    # interface loopback-only and access it through an SSH tunnel.
    networking.firewall.interfaces.tailscale0 = {
      allowedTCPPorts = [
        47984
        47989
        48010
      ];
      allowedUDPPorts = [
        47998
        47999
        48000
        48002
        48010
      ];
    };

    users.users.${user} = {
      linger = true;
      extraGroups = [
        "input"
        "video"
        "render"
        "uinput"
      ];
    };

    services.pipewire.extraConfig.pipewire."90-game-stream" = {
      "context.objects" = [
        {
          factory = "adapter";
          args = {
            "factory.name" = "support.null-audio-sink";
            "node.name" = "game-stream";
            "node.description" = "Game streaming";
            "media.class" = "Audio/Sink";
            "audio.position" = [
              "FL"
              "FR"
            ];
          };
        }
      ];
    };

    systemd.user.services.game-stream-session = {
      description = "Headless Wayland session for game streaming";
      # Sunshine probes the display before running application prep commands.
      # Keep Sway available, but leave Steam off until a Steam app is selected.
      wantedBy = [ "default.target" ];
      unitConfig.ConditionUser = user;
      # Sway runs exec commands through `sh` looked up in PATH.
      path = [ pkgs.bash ];
      environment = sessionEnvironment // {
        WLR_BACKENDS = "headless,libinput";
        WLR_HEADLESS_OUTPUTS = "1";
        WLR_LIBINPUT_NO_DEVICES = "1";
        WLR_RENDERER = "gles2";
        LIBSEAT_BACKEND = "noop";
        WLR_XWAYLAND = lib.getExe pkgs.xwayland;
        SWAYSOCK = "%t/game-stream/sway.sock";
      };
      serviceConfig = {
        Type = "notify";
        NotifyAccess = "all";
        RuntimeDirectory = "game-stream";
        RuntimeDirectoryMode = "0700";
        ExecStart = startSession;
        Restart = "on-failure";
        RestartSec = 5;
        TimeoutStartSec = 30;
      };
    };

    systemd.user.services.sunshine = {
      wantedBy = [ "default.target" ];
      partOf = lib.mkForce [ "game-stream-session.service" ];
      wants = lib.mkForce [ "pipewire-pulse.service" ];
      requires = [ "game-stream-session.service" ];
      after = lib.mkForce [
        "game-stream-session.service"
        "pipewire-pulse.service"
      ];
      unitConfig.ConditionUser = user;
      environment = sessionEnvironment;
      serviceConfig.EnvironmentFile = "%t/game-stream/session.env";
    };

    systemd.user.services.game-stream-steam = {
      description = "Steam Big Picture in the headless Wayland session";
      partOf = [ "game-stream-session.service" ];
      requires = [ "game-stream-session.service" ];
      after = [
        "game-stream-session.service"
        "pipewire-pulse.service"
      ];
      unitConfig.ConditionUser = user;
      environment = sessionEnvironment;
      serviceConfig = {
        EnvironmentFile = "%t/game-stream/session.env";
        ExecStartPre = checkSteam;
        ExecStart = "${lib.getExe config.programs.steam.package} -bigpicture";
        # Steam may replace its launcher during updates. Track its children
        # until the client exits, and keep them owned by this service for stop.
        ExitType = "cgroup";
      };
    };

    environment.systemPackages = [
      (pkgs.writeShellApplication {
        name = "game-stream-host";
        runtimeInputs = [ pkgs.systemd ];
        text = ''
          case "''${1:-status}" in
            start) systemctl --user start game-stream-session sunshine ;;
            stop) systemctl --user stop game-stream-session ;;
            status) systemctl --user status game-stream-session sunshine game-stream-steam ;;
            *) echo "Usage: game-stream-host [start|stop|status]" >&2; exit 2 ;;
          esac
        '';
      })
    ];

    # Keep Sunshine's keyboard/mouse out of the physical Hyprland session.
    # Sway still sees them through libinput and enables them explicitly above.
    home-manager.users.${user}.wayland.windowManager.hyprland.settings.device =
      map
        (name: {
          inherit name;
          enabled = false;
        })
        [
          "keyboard-passthrough"
          "mouse-passthrough"
          "mouse-passthrough-(absolute)"
          "touch-passthrough"
          "pen-passthrough"
          "sunshine-ps5-(virtual)-pad-touchpad"
        ];
  };
}
