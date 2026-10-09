{ ... }:

{
  flake.modules.homeManager.agent-tools =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      updater = pkgs.writeShellApplication {
        name = "agent-tools-update";
        runtimeInputs = [
          pkgs.python3
          pkgs.libnotify
        ];
        text = ''exec python3 ${./_agent-tools/update.py} "$@"'';
      };
      codex = pkgs.writeShellApplication {
        name = "codex";
        runtimeInputs = [ pkgs.bubblewrap ];
        text = ''
          data="''${XDG_DATA_HOME:-$HOME/.local/share}/agent-tools"
          if ! ${lib.getExe updater} --max-age 300 codex >&2; then
            if [[ ! -x "$data/codex/current/bin/codex" ]]; then
              exit 1
            fi
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
          if ! ${lib.getExe updater} --notify --max-age 300; then
            if [[ ! -x "$data/t3code/current/T3.AppImage" || ! -x "$data/codex/current/bin/codex" ]]; then
              exit 1
            fi
          fi
          export PATH="${lib.makeBinPath [ codex ]}:$PATH"
          notify-send --app-name="T3 Code" --icon=t3code-nightly \
            "T3 Code" "Opening T3 Code Nightly; the first launch of a new version unpacks the AppImage…" || true
          # Resolve the version now so an update cannot change the file while appimage-run reads it.
          image=$(readlink -f "$data/t3code/current/T3.AppImage")
          exec appimage-run "$image" "$@"
        '';
      };
    in
    {
      home.packages = [
        codex
        t3
        updater
      ];
      xdg.dataFile."icons/hicolor/512x512/apps/t3code-nightly.png".source =
        ./_agent-tools/t3code-nightly.png;
      xdg.desktopEntries.t3code = {
        name = "T3 Code Nightly";
        comment = "Nightly T3 Code with the latest Codex CLI";
        exec = "${lib.getExe t3} %U";
        icon = "t3code-nightly";
        terminal = false;
        categories = [ "Development" ];
        mimeType = [ "x-scheme-handler/t3code" ];
        settings.StartupWMClass = "t3code";
      };
      xdg.desktopEntries."com.t3tools.T3Code" = {
        name = "T3 Code Nightly";
        exec = "${lib.getExe t3} %U";
        icon = "t3code-nightly";
        noDisplay = true;
        mimeType = [ "x-scheme-handler/t3code" ];
      };
      xdg.mimeApps.defaultApplications."x-scheme-handler/t3code" = [ "t3code.desktop" ];
      # User desktop files take precedence over the Home Manager package entry.
      # Retire the old Downloads shortcut without touching custom launchers.
      home.activation.retireLegacyT3Launcher = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        legacy=${lib.escapeShellArg "${config.xdg.dataHome}/applications/t3code.desktop"}
        backup=${lib.escapeShellArg "${config.xdg.stateHome}/agent-tools/legacy-launchers"}
        if [ -f "$legacy" ] && [ ! -L "$legacy" ] && \
          ${pkgs.gnugrep}/bin/grep -Eq '^Exec=nix run nixpkgs#appimage-run -- /[^ ]*/Downloads/T3-Code-[^ ]+\.AppImage %u$' "$legacy"; then
          run ${pkgs.coreutils}/bin/mkdir -p "$backup"
          run ${pkgs.coreutils}/bin/mv --backup=numbered "$legacy" "$backup/t3code.desktop"
        fi
      '';
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
