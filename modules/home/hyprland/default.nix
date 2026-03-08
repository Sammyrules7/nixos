{ inputs, pkgs, ... }:

{
  imports = [
    ./autostart.nix
    ./binds.nix
    ./hyprpanel.nix
    ./input.nix
    ./permissions.nix
    ./pretty.nix
    ./windowrules.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      general = {
        allow_tearing = true;
      };
      env = [
        #"GTK_SCALE,0.75"
        #"QT_SCALE_FACTOR,0.75"
      ];
    };
  };

  programs.hyprpanel.enable = true;
}
