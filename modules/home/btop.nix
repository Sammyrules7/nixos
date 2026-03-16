{ config, lib, ... }:

{
  options.features.btop.enable = lib.mkEnableOption "btop system monitor";

  config = lib.mkIf config.features.btop.enable {
    programs.btop = {
      enable = true;
      settings = {
        theme_background = false;
        truecolor = true;
        terminal_sync = true;
        graph_symbol = "braille";
        shown_boxes = "cpu mem net proc gpu0";
        update_ms = 200;
        proc_colors = true;
        proc_gradient = true;
        show_uptime = true;
        show_cpu_watts = true;
        check_temp = true;
      };
    };
  };
}
