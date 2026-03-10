{ inputs, ... }:
{
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
      theme = "frosted-glass";
    };
    themes."frosted-glass" = {
      style = ''
        /* Override colors with transparency */
        @define-color window_bg_color rgba(31, 31, 40, 0.5);
        @define-color accent_bg_color rgba(84, 84, 109, 0.4);
        @define-color theme_fg_color #f2ecbc;

        /* Basic resets and glass effect for the main container */
        * { all: unset; }

        .box-wrapper {
          background: @window_bg_color;
          border-radius: 20px;
          border: 1px solid rgba(242, 236, 188, 0.1);
          padding: 20px;
          box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
        }

        /* Search Input */
        .input {
          background: rgba(31, 31, 40, 0.3);
          color: @theme_fg_color;
          padding: 10px;
          border-radius: 10px;
          caret-color: @theme_fg_color;
        }

        /* List Items */
        .item-box {
          padding: 10px;
          border-radius: 10px;
        }

        /* Selected Item (The 'Glass' highlight) */
        child:selected .item-box,
        row:selected .item-box {
          background: @accent_bg_color;
        }

        /* Text and Icons */
        .list { color: @theme_fg_color; }
        .item-subtext { font-size: 12px; opacity: 0.5; }
        .normal-icons { -gtk-icon-size: 16px; }
        .large-icons { -gtk-icon-size: 32px; }

        /* Scrollbar and popover */
        scrollbar { opacity: 0; }
        popover {
          background: rgba(31, 31, 40, 0.9);
          border: 1px solid @accent_bg_color;
          border-radius: 18px;
          padding: 10px;
        }
      '';
    };
  };
}
