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
        ui.width = 450;
        list.height = 400;
        modules = [
          {
            name = "applications";
            prefix = "";
          }
          {
            name = "commands";
            prefix = ":";
          }
          {
            name = "websearch";
            prefix = "?";
          }
          {
            name = "calculator";
            prefix = "=";
          }
          {
            name = "power";
            prefix = "!";
          }
          {
            name = "finder";
            prefix = "/";
          }
        ];
      };
    };
  };
}
