{ lib, pkgs, ... }:

let
  # Mirror text selections into XWayland for Wine applications such as VRChat.
  syncWaylandClipboardToX11 = pkgs.writeShellApplication {
    name = "sync-wayland-clipboard-to-x11";
    runtimeInputs = with pkgs; [
      coreutils
      wl-clipboard
      xclip
    ];
    text = ''
      runtime_dir="''${XDG_RUNTIME_DIR:?XDG_RUNTIME_DIR is not set}"
      state_file="$runtime_dir/wayland-to-x11-clipboard.sha256"
      clipboard_file="$(mktemp "$runtime_dir/wayland-to-x11-clipboard.XXXXXX")"
      trap 'rm -f "$clipboard_file"' EXIT

      cat > "$clipboard_file"
      clipboard_hash="$(sha256sum "$clipboard_file" | cut -d ' ' -f 1)"

      if [[ -r "$state_file" ]] && [[ "$(< "$state_file")" == "$clipboard_hash" ]]; then
        exit 0
      fi

      xclip -selection clipboard -in < "$clipboard_file"
      printf '%s\n' "$clipboard_hash" > "$state_file"
    '';
  };
in
{
  home.packages = [ syncWaylandClipboardToX11 ];

  wayland.windowManager.hyprland.settings.on = {
    _args = [
      "hyprland.start"
      (lib.generators.mkLuaInline ''
        function()
          hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
          hl.exec_cmd("${lib.getExe' pkgs.wl-clipboard "wl-paste"} --type text --watch ${lib.getExe syncWaylandClipboardToX11}")
        end
      '')
    ];
  };
}
