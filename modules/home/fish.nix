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
      '';
    };
  };
}
