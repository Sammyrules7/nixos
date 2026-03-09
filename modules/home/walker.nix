{ inputs, ... }: {
  imports = [
    inputs.walker.homeManagerModules.default
  ];

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
}
