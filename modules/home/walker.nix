{
  config,
  lib,
  inputs,
  ...
}:

{
  imports = [
    inputs.walker.homeManagerModules.default
  ];

  options.features.walker.enable = lib.mkEnableOption "Walker application launcher";

  config = lib.mkIf config.features.walker.enable {
    programs.walker = {
      enable = true;
      runAsService = true;
      config = {
        search.placeholder = "Search...";
        ui.fullscreen = false;
        ui.width = 400;
        list.height = 300;
      };
    };
  };
}
