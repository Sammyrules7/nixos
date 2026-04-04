{
  config,
  lib,
  ...
}:

{
  options.features.fish.enable = lib.mkEnableOption "Fish shell configuration";

  config = lib.mkIf config.features.fish.enable {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting

        # Disable fish mouse handling to prevent it from stealing right click
        set -g fish_handle_mouse 0
        functions -e __fish_on_mouse_down
        functions -e __fish_on_mouse_up
        functions -e __fish_on_mouse_double_down
        functions -e __fish_on_mouse_triple_down

        # Ghostty shell integration
        if set -q GHOSTTY_RESOURCES_DIR
            source "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
        end
      '';
    };
  };
}
