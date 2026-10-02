{ ... }:

{
  flake.modules.homeManager.agent-tools =
    {
      pkgs,
      lib,
      ...
    }:
    let
      updater = pkgs.writeShellApplication {
        name = "agent-tools-update";
        runtimeInputs = [ pkgs.python3 ];
        text = ''exec python3 ${./_agent-tools/update.py} "$@"'';
      };
      codex = pkgs.writeShellApplication {
        name = "codex";
        text = ''
          data="''${XDG_DATA_HOME:-$HOME/.local/share}/agent-tools"
          if [[ ! -x "$data/codex/current/bin/codex" ]]; then
            ${lib.getExe updater} codex
          fi
          exec "$data/codex/current/bin/codex" "$@"
        '';
      };
      t3 = pkgs.writeShellApplication {
        name = "t3code";
        runtimeInputs = [
          pkgs.appimage-run
          pkgs.libnotify
        ];
        text = ''
          data="''${XDG_DATA_HOME:-$HOME/.local/share}/agent-tools"
          if ! ${lib.getExe updater}; then
            notify-send "T3 Code" "Update unavailable; using the installed version."
          fi
          export PATH="${lib.makeBinPath [ codex ]}:$PATH"
          exec appimage-run "$data/t3code/current/T3.AppImage" "$@"
        '';
      };
    in
    {
      home.packages = [
        codex
        t3
        updater
      ];
      xdg.desktopEntries.t3code = {
        name = "T3 Code Nightly";
        comment = "Nightly T3 Code with the latest Codex CLI";
        exec = "${lib.getExe t3} %U";
        icon = "applications-development";
        terminal = false;
        categories = [ "Development" ];
        mimeType = [ "x-scheme-handler/t3code" ];
      };
      xdg.desktopEntries."com.t3tools.T3Code" = {
        name = "T3 Code Nightly";
        exec = "${lib.getExe t3} %U";
        icon = "applications-development";
        noDisplay = true;
        mimeType = [ "x-scheme-handler/t3code" ];
      };
      xdg.mimeApps.defaultApplications."x-scheme-handler/t3code" = [ "t3code.desktop" ];
      systemd.user.services.agent-tools-update = {
        Unit.Description = "Update T3 Code nightly and Codex CLI";
        Service = {
          Type = "oneshot";
          ExecStart = lib.getExe updater;
          Nice = 19;
          IOSchedulingClass = "idle";
          CPUQuota = "25%";
        };
      };
      systemd.user.timers.agent-tools-update = {
        Unit.Description = "Check upstream agent releases hourly";
        Timer = {
          OnStartupSec = "2m";
          OnUnitActiveSec = "1h";
          RandomizedDelaySec = "5m";
        };
        Install.WantedBy = [ "timers.target" ];
      };
    };
}
