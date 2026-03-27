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
        theme = "default";
        force_keyboard_focus = false;
        close_when_open = true;
        click_to_close = true;
        as_window = false;
        single_click_activation = true;
        selection_wrap = false;
        global_argument_delimiter = "#";
        exact_search_prefix = "'";
        disable_mouse = false;
        debug = false;
        page_jump_items = 10;
        hide_quick_activation = false;
        hide_action_hints = false;
        hide_action_hints_dmenu = true;
        hide_return_action = false;
        resume_last_query = false;
        actions_as_menu = false;
        autoplay_videos = false;

        shell = {
          exclusive_zone = -1;
          layer = "overlay";
          anchor_top = true;
          anchor_bottom = true;
          anchor_left = true;
          anchor_right = true;
        };

        placeholders = {
          "default" = {
            input = "Search";
            list = "No Results";
          };
        };

        keybinds = {
          close = [ "Escape" ];
          next = [ "Down" ];
          previous = [ "Up" ];
          left = [ "Left" ];
          right = [ "Right" ];
          down = [ "Down" ];
          up = [ "Up" ];
          toggle_exact = [ "ctrl e" ];
          resume_last_query = [ "ctrl r" ];
          quick_activate = [
            "F1"
            "F2"
            "F3"
            "F4"
          ];
          page_down = [ "Page_Down" ];
          page_up = [ "Page_Up" ];
          show_actions = [ "alt j" ];
        };

        providers = {
          default = [
            "desktopapplications"
            "calc"
            "websearch"
          ];
          empty = [ "desktopapplications" ];
          max_results = 50;
          prefixes = [
            {
              prefix = ";";
              provider = "providerlist";
            }
            {
              prefix = ">";
              provider = "runner";
            }
            {
              prefix = "/";
              provider = "files";
            }
            {
              prefix = ".";
              provider = "symbols";
            }
            {
              prefix = "!";
              provider = "todo";
            }
            {
              prefix = "%";
              provider = "bookmarks";
            }
            {
              prefix = "=";
              provider = "calc";
            }
            {
              prefix = "@";
              provider = "websearch";
            }
            {
              prefix = ":";
              provider = "clipboard";
            }
            {
              prefix = "$";
              provider = "windows";
            }
          ];

          actions = {
            fallback = [
              {
                action = "menus:open";
                label = "open";
                after = "Nothing";
              }
              {
                action = "menus:default";
                label = "run";
                after = "Close";
              }
              {
                action = "menus:parent";
                label = "back";
                bind = "Escape";
                after = "Nothing";
              }
              {
                action = "erase_history";
                label = "clear hist";
                bind = "ctrl h";
                after = "AsyncReload";
              }
            ];

            dmenu = [
              {
                action = "select";
                default = true;
                bind = "Return";
              }
            ];

            providerlist = [
              {
                action = "activate";
                default = true;
                bind = "Return";
                after = "ClearReload";
              }
            ];

            calc = [
              {
                action = "copy";
                default = true;
                bind = "Return";
              }
              {
                action = "delete";
                bind = "ctrl d";
                after = "AsyncReload";
              }
              {
                action = "delete_all";
                bind = "ctrl shift d";
                after = "AsyncReload";
              }
              {
                action = "save";
                bind = "ctrl s";
                after = "AsyncClearReload";
              }
            ];

            websearch = [
              {
                action = "search";
                default = true;
                bind = "Return";
              }
              {
                action = "open_url";
                label = "open url";
                default = true;
                bind = "Return";
              }
            ];

            desktopapplications = [
              {
                action = "start";
                default = true;
                bind = "Return";
              }
              {
                action = "start:keep";
                label = "open+next";
                bind = "shift Return";
                after = "KeepOpen";
              }
              {
                action = "new_instance";
                label = "new instance";
                bind = "ctrl Return";
              }
              {
                action = "new_instance:keep";
                label = "new+next";
                bind = "ctrl alt Return";
                after = "KeepOpen";
              }
              {
                action = "pin";
                bind = "ctrl p";
                after = "AsyncReload";
              }
              {
                action = "unpin";
                bind = "ctrl p";
                after = "AsyncReload";
              }
              {
                action = "pinup";
                bind = "ctrl n";
                after = "AsyncReload";
              }
              {
                action = "pindown";
                bind = "ctrl m";
                after = "AsyncReload";
              }
            ];
          };
        };
      };

      themes.default = {
        style = ''
          @define-color window_bg_color rgba(0, 0, 0, 0.004);
          @define-color accent_bg_color rgba(255, 255, 255, 0.2);
          @define-color theme_fg_color #f2ecbc;
          @define-color error_bg_color #C34043;
          @define-color error_fg_color #DCD7BA;

          * {
            all: unset;
          }

          #window {
            background-color: transparent;
          }

          popover {
            background: lighter(@window_bg_color);
            border: 1px solid darker(@accent_bg_color);
            border-radius: 18px;
            padding: 10px;
          }

          .normal-icons {
            -gtk-icon-size: 16px;
          }

          .large-icons {
            -gtk-icon-size: 32px;
          }

          scrollbar {
            opacity: 0;
          }

          .box-wrapper {
            background: @window_bg_color;
            padding: 20px;
            border-radius: 20px;
            border: 1px solid darker(@accent_bg_color);
          }

          .preview-box,
          .elephant-hint,
          .placeholder {
            color: @theme_fg_color;
          }

          .box {
          }

          .search-container {
            border-radius: 10px;
          }

          .input placeholder {
            opacity: 0.5;
          }

          .input selection {
            background: lighter(lighter(lighter(@window_bg_color)));
          }

          .input {
            caret-color: @theme_fg_color;
            background: lighter(@window_bg_color);
            padding: 10px;
            color: @theme_fg_color;
            border-radius: 10px;
          }

          .input:focus,
          .input:active {
          }

          .content-container {
          }

          .placeholder {
          }

          .scroll {
          }

          .list {
            color: @theme_fg_color;
          }

          child {
          }

          .item-box {
            border-radius: 10px;
            padding: 10px;
          }

          .item-quick-activation {
            background: alpha(@accent_bg_color, 0.25);
            border-radius: 5px;
            padding: 10px;
          }

          /* child:hover .item-box, */
          child:selected .item-box,
          row:selected .item-box {
            background: alpha(@accent_bg_color, 0.25);
          }

          .item-text-box {
          }

          .item-subtext {
            font-size: 12px;
            opacity: 0.5;
          }

          .providerlist .item-subtext {
            font-size: unset;
            opacity: 0.75;
          }

          .item-image-text {
            font-size: 28px;
          }

          .preview {
            border: 1px solid alpha(@accent_bg_color, 0.25);
            /* padding: 10px; */
            border-radius: 10px;
            color: @theme_fg_color;
          }

          .calc .item-text {
            font-size: 24px;
          }

          .calc .item-subtext {
          }

          .symbols .item-image {
            font-size: 24px;
          }

          .todo.done .item-text-box {
            opacity: 0.25;
          }

          .todo.urgent {
            font-size: 24px;
          }

          .todo.active {
            font-weight: bold;
          }

          .bluetooth.disconnected {
            opacity: 0.5;
          }

          .preview .large-icons {
            -gtk-icon-size: 64px;
          }

          .keybinds {
            padding-top: 10px;
            border-top: 1px solid lighter(@window_bg_color);
            font-size: 12px;
            color: @theme_fg_color;
          }

          .global-keybinds {
          }

          .item-keybinds {
          }

          .keybind {
          }

          .keybind-button {
            opacity: 0.5;
          }

          .keybind-button:hover {
            opacity: 0.75;
          }

          .keybind-bind {
            text-transform: lowercase;
            opacity: 0.35;
          }

          .keybind-label {
            padding: 2px 4px;
            border-radius: 4px;
            border: 1px solid @theme_fg_color;
          }

          .error {
            padding: 10px;
            background: @error_bg_color;
            color: @error_fg_color;
          }

          :not(.calc).current {
            font-style: italic;
          }

          .preview-content.archlinuxpkgs,
          .preview-content.dnfpackages {
            font-family: monospace;
          }
        '';
        layouts = {
          item = ''
            <?xml version="1.0" encoding="UTF-8"?>
            <interface>
              <requires lib="gtk" version="4.0"></requires>
              <object class="GtkBox" id="ItemBox">
                <style>
                  <class name="item-box"></class>
                </style>
                <property name="orientation">horizontal</property>
                <property name="spacing">10</property>
                <child>
                  <object class="GtkLabel" id="ItemImageFont">
                    <style>
                      <class name="item-image-text"></class>
                    </style>
                    <property name="width-chars">2</property>
                  </object>
                </child>
                <child>
                  <object class="GtkImage" id="ItemImage">
                    <style>
                      <class name="item-image"></class>
                    </style>
                    <property name="icon-size">large</property>
                  </object>
                </child>
                <child>
                  <object class="GtkBox" id="ItemTextBox">
                    <style>
                      <class name="item-text-box"></class>
                    </style>
                    <property name="orientation">vertical</property>
                    <property name="vexpand">true</property>
                    <property name="hexpand">true</property>
                    <property name="vexpand-set">true</property>
                    <property name="spacing">0</property>
                    <child>
                      <object class="GtkLabel" id="ItemText">
                        <style>
                          <class name="item-text"></class>
                        </style>
                        <property name="ellipsize">end</property>
                        <property name="vexpand_set">true</property>
                        <property name="vexpand">true</property>
                        <property name="xalign">0</property>
                      </object>
                    </child>
                    <child>
                      <object class="GtkLabel" id="ItemSubtext">
                        <style>
                          <class name="item-subtext"></class>
                        </style>
                        <property name="ellipsize">end</property>
                        <property name="vexpand_set">true</property>
                        <property name="vexpand">true</property>
                        <property name="xalign">0</property>
                        <property name="yalign">0</property>
                      </object>
                    </child>
                  </object>
                </child>
                <child>
                  <object class="GtkLabel" id="QuickActivation">
                    <style>
                      <class name="item-quick-activation"></class>
                    </style>
                    <property name="wrap">false</property>
                    <property name="valign">center</property>
                    <property name="xalign">0</property>
                    <property name="yalign">0.5</property>
                  </object>
                </child>
              </object>
            </interface>
          '';
          item_actionsmenu = ''
            <?xml version="1.0" encoding="UTF-8"?>
            <interface>
              <requires lib="gtk" version="4.0"></requires>
              <object class="GtkBox" id="ItemBox">
                <style>
                  <class name="item-box"></class>
                </style>
                <property name="orientation">horizontal</property>
                <property name="spacing">10</property>
                <child>
                  <object class="GtkLabel" id="ItemImageFont">
                    <style>
                      <class name="item-image-text"></class>
                    </style>
                    <property name="width-chars">2</property>
                  </object>
                </child>
                <child>
                  <object class="GtkImage" id="ItemImage">
                    <style>
                      <class name="item-image"></class>
                    </style>
                    <property name="icon-size">large</property>
                  </object>
                </child>
                <child>
                  <object class="GtkBox" id="ItemTextBox">
                    <style>
                      <class name="item-text-box"></class>
                    </style>
                    <property name="orientation">horizontal</property>
                    <property name="vexpand">true</property>
                    <property name="hexpand">true</property>
                    <property name="vexpand-set">true</property>
                    <property name="spacing">0</property>
                    <child>
                      <object class="GtkLabel" id="ItemText">
                        <style>
                          <class name="item-text"></class>
                        </style>
                        <property name="ellipsize">end</property>
                        <property name="vexpand_set">true</property>
                        <property name="vexpand">true</property>
                        <property name="hexpand">true</property>
                        <property name="xalign">0</property>
                      </object>
                    </child>
                    <child>
                      <object class="GtkLabel" id="ItemSubtext">
                        <style>
                          <class name="item-subtext"></class>
                        </style>
                        <property name="ellipsize">end</property>
                        <property name="vexpand_set">true</property>
                        <property name="vexpand">true</property>
                        <property name="xalign">0</property>
                        <property name="yalign">0.5</property>
                      </object>
                    </child>
                  </object>
                </child>
              </object>
            </interface>
          '';
          item_archlinuxpkgs = ''
            <?xml version="1.0" encoding="UTF-8"?>
            <interface>
              <requires lib="gtk" version="4.0"></requires>
              <object class="GtkBox" id="ItemBox">
                <style>
                  <class name="item-box"></class>
                </style>
                <property name="orientation">horizontal</property>
                <property name="spacing">10</property>
                <child>
                  <object class="GtkBox" id="ItemTextBox">
                    <style>
                      <class name="item-text-box"></class>
                    </style>
                    <property name="orientation">vertical</property>
                    <property name="vexpand">true</property>
                    <property name="hexpand">true</property>
                    <property name="vexpand-set">true</property>
                    <property name="spacing">0</property>
                    <child>
                      <object class="GtkLabel" id="ItemText">
                        <style>
                          <class name="item-text"></class>
                        </style>
                        <property name="wrap">false</property>
                        <property name="vexpand_set">true</property>
                        <property name="vexpand">true</property>
                        <property name="xalign">0</property>
                      </object>
                    </child>
                    <child>
                      <object class="GtkLabel" id="ItemSubtext">
                        <style>
                          <class name="item-subtext"></class>
                        </style>
                        <property name="wrap">true</property>
                        <property name="vexpand_set">true</property>
                        <property name="vexpand">true</property>
                        <property name="xalign">0</property>
                        <property name="yalign">0</property>
                      </object>
                    </child>
                  </object>
                </child>
                <child>
                  <object class="GtkLabel" id="QuickActivation">
                    <style>
                      <class name="item-quick-activation"></class>
                    </style>
                    <property name="wrap">false</property>
                    <property name="valign">center</property>
                    <property name="xalign">0</property>
                    <property name="yalign">0.5</property>
                  </object>
                </child>
              </object>
            </interface>
          '';
          item_bookmarks = ''
            <?xml version="1.0" encoding="UTF-8"?>
            <interface>
              <requires lib="gtk" version="4.0"></requires>
              <object class="GtkBox" id="ItemBox">
                <style>
                  <class name="item-box"></class>
                </style>
                <property name="orientation">horizontal</property>
                <property name="spacing">10</property>
                <child>
                  <object class="GtkLabel" id="ItemImageFont">
                    <style>
                      <class name="item-image-text"></class>
                    </style>
                    <property name="width-chars">2</property>
                  </object>
                </child>
                <child>
                  <object class="GtkImage" id="ItemImage">
                    <style>
                      <class name="item-image"></class>
                    </style>
                    <property name="icon-size">large</property>
                  </object>
                </child>
                <child>
                  <object class="GtkImage" id="ItemImageCreate">
                    <style>
                      <class name="item-image"></class>
                    </style>
                    <property name="pixel-size">48</property>
                  </object>
                </child>
                <child>
                  <object class="GtkBox" id="ItemTextBox">
                    <style>
                      <class name="item-text-box"></class>
                    </style>
                    <property name="orientation">vertical</property>
                    <property name="vexpand">true</property>
                    <property name="vexpand-set">true</property>
                    <property name="spacing">0</property>
                    <child>
                      <object class="GtkLabel" id="ItemText">
                        <style>
                          <class name="item-text"></class>
                        </style>
                        <property name="wrap">true</property>
                        <property name="vexpand_set">true</property>
                        <property name="vexpand">true</property>
                        <property name="hexpand">true</property>
                        <property name="xalign">0</property>
                      </object>
                    </child>
                    <child>
                      <object class="GtkLabel" id="ItemSubtext">
                        <style>
                          <class name="item-subtext"></class>
                        </style>
                        <property name="wrap">true</property>
                        <property name="vexpand_set">true</property>
                        <property name="vexpand">true</property>
                        <property name="xalign">0</property>
                        <property name="yalign">0</property>
                      </object>
                    </child>
                  </object>
                </child>
                <child>
                  <object class="GtkLabel" id="QuickActivation">
                    <style>
                      <class name="item-quick-activation"></class>
                    </style>
                    <property name="wrap">false</property>
                    <property name="valign">center</property>
                    <property name="xalign">0</property>
                    <property name="yalign">0.5</property>
                  </object>
                </child>
              </object>
            </interface>
          '';
          item_calc = ''
            <?xml version="1.0" encoding="UTF-8"?>
            <interface>
              <requires lib="gtk" version="4.0"></requires>
              <object class="GtkBox" id="ItemBox">
                <style>
                  <class name="item-box"></class>
                </style>
                <property name="orientation">horizontal</property>
                <property name="spacing">10</property>
                <child>
                  <object class="GtkLabel" id="ItemImageFont">
                    <style>
                      <class name="item-image-text"></class>
                    </style>
                    <property name="width-chars">2</property>
                    <property name="hexpand">false</property>
                  </object>
                </child>
                <child>
                  <object class="GtkImage" id="ItemImage">
                    <style>
                      <class name="item-image"></class>
                    </style>
                    <property name="pixel-size">48</property>
                  </object>
                </child>
                <child>
                  <object class="GtkBox" id="ItemTextBox">
                    <style>
                      <class name="item-text-box"></class>
                    </style>
                    <property name="orientation">vertical</property>
                    <property name="hexpand">true</property>
                    <property name="vexpand">true</property>
                    <property name="vexpand-set">true</property>
                    <property name="spacing">0</property>
                    <child>
                      <object class="GtkLabel" id="ItemText">
                        <style>
                          <class name="item-text"></class>
                        </style>
                        <property name="wrap">false</property>
                        <property name="vexpand_set">true</property>
                        <property name="vexpand">true</property>
                        <property name="xalign">0</property>
                      </object>
                    </child>
                    <child>
                      <object class="GtkLabel" id="ItemSubtext">
                        <style>
                          <class name="item-subtext"></class>
                        </style>
                        <property name="wrap">true</property>
                        <property name="vexpand_set">true</property>
                        <property name="vexpand">true</property>
                        <property name="xalign">0</property>
                        <property name="yalign">0</property>
                      </object>
                    </child>
                  </object>
                </child>
                <child>
                  <object class="GtkLabel" id="QuickActivation">
                    <style>
                      <class name="item-quick-activation"></class>
                    </style>
                    <property name="wrap">false</property>
                    <property name="valign">center</property>
                    <property name="xalign">0</property>
                    <property name="yalign">0.5</property>
                  </object>
                </child>
              </object>
            </interface>
          '';
          item_clipboard = ''
            <?xml version="1.0" encoding="UTF-8"?>
            <interface>
              <requires lib="gtk" version="4.0"></requires>
              <object class="GtkBox" id="ItemBox">
                <style>
                  <class name="item-box"></class>
                </style>
                <property name="orientation">horizontal</property>
                <property name="spacing">10</property>
                <child>
                  <object class="GtkBox">
                    <property name="orientation">vertical</property>
                    <property name="spacing">5</property>
                    <child>
                      <object class="GtkBox" id="ItemTextBox">
                        <style>
                          <class name="item-text-box"></class>
                        </style>
                        <property name="orientation">vertical</property>
                        <property name="hexpand">true</property>
                        <property name="vexpand">true</property>
                        <property name="vexpand-set">true</property>
                        <property name="spacing">0</property>
                        <child>
                          <object class="GtkLabel" id="ItemText">
                            <style>
                              <class name="item-text"></class>
                            </style>
                            <property name="vexpand">true</property>
                            <property name="xalign">0</property>
                            <property name="lines">1</property>
                            <property name="wrap">true</property>
                            <property name="ellipsize">3</property>
                            <property name="single-line-mode">true</property>
                          </object>
                        </child>
                        <child>
                          <object class="GtkLabel" id="ItemSubtext">
                            <style>
                              <class name="item-subtext"></class>
                            </style>
                            <property name="xalign">0</property>
                          </object>
                        </child>
                      </object>
                    </child>
                  </object>
                </child>
                <child>
                  <object class="GtkLabel" id="QuickActivation">
                    <style>
                      <class name="item-quick-activation"></class>
                    </style>
                    <property name="wrap">false</property>
                    <property name="valign">center</property>
                    <property name="xalign">0</property>
                    <property name="yalign">0.5</property>
                  </object>
                </child>
              </object>
            </interface>
          '';
          item_dmenu = ''
            <?xml version="1.0" encoding="UTF-8"?>
            <interface>
              <requires lib="gtk" version="4.0"></requires>
              <object class="GtkBox" id="ItemBox">
                <style>
                  <class name="item-box"></class>
                </style>
                <property name="orientation">horizontal</property>
                <property name="spacing">10</property>
                <child>
                  <object class="GtkBox" id="ItemTextBox">
                    <style>
                      <class name="item-text-box"></class>
                    </style>
                    <property name="orientation">vertical</property>
                    <property name="hexpand">true</property>
                    <property name="vexpand">true</property>
                    <property name="vexpand-set">true</property>
                    <property name="spacing">0</property>
                    <child>
                      <object class="GtkLabel" id="ItemText">
                        <style>
                          <class name="item-text"></class>
                        </style>
                        <property name="vexpand">true</property>
                        <property name="xalign">0</property>
                        <property name="lines">1</property>
                        <property name="ellipsize">3</property>
                        <property name="single-line-mode">true</property>
                      </object>
                    </child>
                  </object>
                </child>
                <child>
                  <object class="GtkLabel" id="QuickActivation">
                    <style>
                      <class name="item-quick-activation"></class>
                    </style>
                    <property name="wrap">false</property>
                    <property name="valign">center</property>
                    <property name="xalign">0</property>
                    <property name="yalign">0.5</property>
                  </object>
                </child>
              </object>
            </interface>
          '';
          item_dnfpackages = ''
            <?xml version="1.0" encoding="UTF-8"?>
            <interface>
              <requires lib="gtk" version="4.0"></requires>
              <object class="GtkBox" id="ItemBox">
                <style>
                  <class name="item-box"></class>
                </style>
                <property name="orientation">horizontal</property>
                <property name="spacing">10</property>
                <child>
                  <object class="GtkBox" id="ItemTextBox">
                    <style>
                      <class name="item-text-box"></class>
                    </style>
                    <property name="orientation">vertical</property>
                    <property name="vexpand">true</property>
                    <property name="hexpand">true</property>
                    <property name="vexpand-set">true</property>
                    <property name="spacing">0</property>
                    <child>
                      <object class="GtkLabel" id="ItemText">
                        <style>
                          <class name="item-text"></class>
                        </style>
                        <property name="wrap">false</property>
                        <property name="vexpand_set">true</property>
                        <property name="vexpand">true</property>
                        <property name="xalign">0</property>
                      </object>
                    </child>
                    <child>
                      <object class="GtkLabel" id="ItemSubtext">
                        <style>
                          <class name="item-subtext"></class>
                        </style>
                        <property name="wrap">true</property>
                        <property name="vexpand_set">true</property>
                        <property name="vexpand">true</property>
                        <property name="xalign">0</property>
                        <property name="yalign">0</property>
                      </object>
                    </child>
                  </object>
                </child>
                <child>
                  <object class="GtkLabel" id="QuickActivation">
                    <style>
                      <class name="item-quick-activation"></class>
                    </style>
                    <property name="wrap">false</property>
                    <property name="valign">center</property>
                    <property name="xalign">0</property>
                    <property name="yalign">0.5</property>
                  </object>
                </child>
              </object>
            </interface>
          '';
          item_files = ''
            <?xml version="1.0" encoding="UTF-8"?>
            <interface>
              <requires lib="gtk" version="4.0"></requires>
              <object class="GtkBox" id="ItemBox">
                <style>
                  <class name="item-box"></class>
                </style>
                <property name="orientation">horizontal</property>
                <property name="spacing">10</property>
                <child>
                  <object class="GtkImage" id="ItemImage">
                    <style>
                      <class name="item-image"></class>
                    </style>
                    <property name="icon-size">large</property>
                  </object>
                </child>
                <child>
                  <object class="GtkBox" id="ItemTextBox">
                    <style>
                      <class name="item-text-box"></class>
                    </style>
                    <property name="orientation">vertical</property>
                    <property name="hexpand">true</property>
                    <property name="vexpand">true</property>
                    <property name="vexpand-set">true</property>
                    <property name="spacing">0</property>
                    <child>
                      <object class="GtkLabel" id="ItemText">
                        <style>
                          <class name="item-text"></class>
                        </style>
                        <property name="wrap">false</property>
                        <property name="vexpand_set">true</property>
                        <property name="vexpand">true</property>
                        <property name="xalign">0</property>
                        <property name="ellipsize">1</property>
                      </object>
                    </child>
                    <child>
                      <object class="GtkLabel" id="ItemSubtext">
                        <style>
                          <class name="item-subtext"></class>
                        </style>
                        <property name="wrap">false</property>
                        <property name="vexpand_set">true</property>
                        <property name="vexpand">true</property>
                        <property name="xalign">0</property>
                        <property name="ellipsize">1</property>
                      </object>
                    </child>
                  </object>
                </child>
                <child>
                  <object class="GtkLabel" id="QuickActivation">
                    <style>
                      <class name="item-quick-activation"></class>
                    </style>
                    <property name="wrap">false</property>
                    <property name="valign">center</property>
                    <property name="xalign">0</property>
                    <property name="yalign">0.5</property>
                  </object>
                </child>
              </object>
            </interface>
          '';
          item_providerlist = ''
            <?xml version="1.0" encoding="UTF-8"?>
            <interface>
              <requires lib="gtk" version="4.0"></requires>
              <object class="GtkBox" id="ItemBox">
                <style>
                  <class name="item-box"></class>
                </style>
                <property name="orientation">horizontal</property>
                <property name="spacing">10</property>
                <child>
                  <object class="GtkLabel" id="ItemImageFont">
                    <style>
                      <class name="item-image-text"></class>
                    </style>
                    <property name="width-chars">2</property>
                  </object>
                </child>
                <child>
                  <object class="GtkImage" id="ItemImage">
                    <style>
                      <class name="item-image"></class>
                    </style>
                    <property name="icon-size">large</property>
                  </object>
                </child>
                <child>
                  <object class="GtkBox" id="ItemTextBox">
                    <style>
                      <class name="item-text-box"></class>
                    </style>
                    <property name="orientation">horizontal</property>
                    <property name="hexpand">true</property>
                    <property name="vexpand">true</property>
                    <property name="vexpand-set">true</property>
                    <property name="spacing">5</property>
                    <child>
                      <object class="GtkLabel" id="ItemText">
                        <style>
                          <class name="item-text"></class>
                        </style>
                        <property name="wrap">false</property>
                        <property name="vexpand_set">true</property>
                        <property name="vexpand">true</property>
                        <property name="xalign">0</property>
                      </object>
                    </child>
                    <child>
                      <object class="GtkLabel" id="ItemSubtext">
                        <style>
                          <class name="item-subtext"></class>
                        </style>
                        <property name="ellipsize">end</property>
                        <property name="vexpand_set">true</property>
                        <property name="vexpand">true</property>
                        <property name="xalign">0</property>
                        <property name="yalign">0.5</property>
                      </object>
                    </child>
                  </object>
                </child>
                <child>
                  <object class="GtkLabel" id="QuickActivation">
                    <style>
                      <class name="item-quick-activation"></class>
                    </style>
                    <property name="wrap">false</property>
                    <property name="valign">center</property>
                    <property name="xalign">0</property>
                    <property name="yalign">0.5</property>
                  </object>
                </child>
              </object>
            </interface>
          '';
          item_symbols = ''
            <?xml version="1.0" encoding="UTF-8"?>
            <interface>
              <requires lib="gtk" version="4.0"></requires>
              <object class="GtkBox" id="ItemBox">
                <style>
                  <class name="item-box"></class>
                </style>
                <property name="orientation">horizontal</property>
                <property name="spacing">10</property>
                <child>
                  <object class="GtkLabel" id="ItemImage">
                    <style>
                      <class name="item-image"></class>
                    </style>
                    <property name="width-chars">2</property>
                  </object>
                </child>
                <child>
                  <object class="GtkBox" id="ItemTextBox">
                    <style>
                      <class name="item-text-box"></class>
                    </style>
                    <property name="orientation">vertical</property>
                    <property name="hexpand">true</property>
                    <property name="vexpand">true</property>
                    <property name="vexpand-set">true</property>
                    <property name="spacing">0</property>
                    <child>
                      <object class="GtkLabel" id="ItemText">
                        <style>
                          <class name="item-text"></class>
                        </style>
                        <property name="wrap">false</property>
                        <property name="vexpand_set">true</property>
                        <property name="vexpand">true</property>
                        <property name="xalign">0</property>
                      </object>
                    </child>
                  </object>
                </child>
                <child>
                  <object class="GtkLabel" id="QuickActivation">
                    <style>
                      <class name="item-quick-activation"></class>
                    </style>
                    <property name="wrap">false</property>
                    <property name="valign">center</property>
                    <property name="xalign">0</property>
                    <property name="yalign">0.5</property>
                  </object>
                </child>
              </object>
            </interface>
          '';
          item_symbols_grid = ''
            <?xml version="1.0" encoding="UTF-8"?>
            <interface>
              <requires lib="gtk" version="4.0"></requires>
              <object class="GtkBox" id="ItemBox">
                <style>
                  <class name="item-box"></class>
                </style>
                <property name="orientation">vertical</property>
                <property name="spacing">10</property>
                <child>
                  <object class="GtkLabel" id="ItemImage">
                    <style>
                      <class name="item-image"></class>
                    </style>
                  </object>
                </child>
                <child>
                  <object class="GtkBox" id="ItemTextBox">
                    <style>
                      <class name="item-text-box"></class>
                    </style>
                    <property name="hexpand">true</property>
                    <property name="hexpand-set">true</property>
                    <child>
                      <object class="GtkLabel" id="ItemText">
                        <style>
                          <class name="item-text"></class>
                        </style>
                        <property name="wrap">true</property>
                        <property name="hexpand">true</property>
                        <property name="xalign">0.5</property>
                        <property name="justify">2</property>
                      </object>
                    </child>
                  </object>
                </child>
              </object>
            </interface>
          '';
          item_todo = ''
            <?xml version="1.0" encoding="UTF-8"?>
            <interface>
              <requires lib="gtk" version="4.0"></requires>
              <object class="GtkBox" id="ItemBox">
                <style>
                  <class name="item-box"></class>
                </style>
                <property name="orientation">horizontal</property>
                <property name="spacing">10</property>
                <child>
                  <object class="GtkImage" id="ItemImage">
                    <style>
                      <class name="item-image"></class>
                    </style>
                    <property name="pixel-size">48</property>
                  </object>
                </child>
                <child>
                  <object class="GtkBox" id="ItemTextBox">
                    <style>
                      <class name="item-text-box"></class>
                    </style>
                    <property name="orientation">vertical</property>
                    <property name="vexpand">true</property>
                    <property name="vexpand-set">true</property>
                    <property name="spacing">0</property>
                    <child>
                      <object class="GtkLabel" id="ItemText">
                        <style>
                          <class name="item-text"></class>
                        </style>
                        <property name="wrap">true</property>
                        <property name="vexpand_set">true</property>
                        <property name="vexpand">true</property>
                        <property name="hexpand">true</property>
                        <property name="xalign">0</property>
                      </object>
                    </child>
                    <child>
                      <object class="GtkLabel" id="ItemSubtext">
                        <style>
                          <class name="item-subtext"></class>
                        </style>
                        <property name="wrap">false</property>
                        <property name="hexpand">true</property>
                        <property name="xalign">0</property>
                        <property name="yalign">0</property>
                      </object>
                    </child>
                  </object>
                </child>
              </object>
            </interface>
          '';
          item_unicode = ''
            <?xml version="1.0" encoding="UTF-8"?>
            <interface>
              <requires lib="gtk" version="4.0"></requires>
              <object class="GtkBox" id="ItemBox">
                <style>
                  <class name="item-box"></class>
                </style>
                <property name="orientation">horizontal</property>
                <property name="spacing">10</property>
                <child>
                  <object class="GtkLabel" id="ItemImage">
                    <style>
                      <class name="item-image"></class>
                    </style>
                    <property name="width-chars">3</property>
                  </object>
                </child>
                <child>
                  <object class="GtkBox" id="ItemTextBox">
                    <style>
                      <class name="item-text-box"></class>
                    </style>
                    <property name="orientation">vertical</property>
                    <property name="hexpand">true</property>
                    <property name="vexpand">true</property>
                    <property name="vexpand-set">true</property>
                    <property name="spacing">0</property>
                    <child>
                      <object class="GtkLabel" id="ItemText">
                        <style>
                          <class name="item-text"></class>
                        </style>
                        <property name="wrap">false</property>
                        <property name="vexpand_set">true</property>
                        <property name="vexpand">true</property>
                        <property name="xalign">0</property>
                      </object>
                    </child>
                  </object>
                </child>
                <child>
                  <object class="GtkLabel" id="QuickActivation">
                    <style>
                      <class name="item-quick-activation"></class>
                    </style>
                    <property name="wrap">false</property>
                    <property name="valign">center</property>
                    <property name="xalign">0</property>
                    <property name="yalign">0.5</property>
                  </object>
                </child>
              </object>
            </interface>
          '';
          keybind = ''
            <?xml version="1.0" encoding="UTF-8"?>
            <interface>
              <requires lib="gtk" version="4.0"></requires>
              <object class="GtkBox" id="Keybind">
                <style>
                  <class name="keybind"></class>
                </style>
                <property name="orientation">vertical</property>
                <child>
                  <object class="GtkButton" id="KeybindButton">
                    <style>
                      <class name="keybind-button"></class>
                    </style>
                    <child>
                      <object class="GtkLabel" id="KeybindLabel">
                        <style>
                          <class name="keybind-label"></class>
                        </style>
                      </object>
                    </child>
                  </object>
                </child>
                <child>
                  <object class="GtkLabel" id="KeybindBind">
                    <property name="margin-top">5</property>
                    <style>
                      <class name="keybind-bind"></class>
                    </style>
                  </object>
                </child>
              </object>
            </interface>
          '';
          layout = ''
            <?xml version="1.0" encoding="UTF-8"?>
            <interface>
              <requires lib="gtk" version="4.0"></requires>
              <object class="GtkWindow" id="Window">
                <style>
                  <class name="window"></class>
                </style>
                <property name="resizable">true</property>
                <property name="title">Walker</property>
                <child>
                  <object class="GtkBox" id="BoxWrapper">
                    <style>
                      <class name="box-wrapper"></class>
                    </style>
                    <property name="overflow">hidden</property>
                    <property name="orientation">horizontal</property>
                    <property name="valign">center</property>
                    <property name="halign">center</property>
                    <property name="width-request">600</property>
                    <property name="height-request">570</property>
                    <child>
                      <object class="GtkBox" id="Box">
                        <style>
                          <class name="box"></class>
                        </style>
                        <property name="orientation">vertical</property>
                        <property name="hexpand-set">true</property>
                        <property name="hexpand">true</property>
                        <property name="spacing">10</property>
                        <child>
                          <object class="GtkBox" id="SearchContainer">
                            <style>
                              <class name="search-container"></class>
                            </style>
                            <property name="overflow">hidden</property>
                            <property name="orientation">horizontal</property>
                            <property name="halign">fill</property>
                            <property name="hexpand-set">true</property>
                            <property name="hexpand">true</property>
                            <child>
                              <object class="GtkEntry" id="Input">
                                <style>
                                  <class name="input"></class>
                                </style>
                                <property name="halign">fill</property>
                                <property name="hexpand-set">true</property>
                                <property name="hexpand">true</property>
                              </object>
                            </child>
                          </object>
                        </child>
                        <child>
                          <object class="GtkBox" id="ContentContainer">
                            <style>
                              <class name="content-container"></class>
                            </style>
                            <property name="orientation">horizontal</property>
                            <property name="spacing">10</property>
                            <child>
                              <object class="GtkLabel" id="ElephantHint">
                                <style>
                                  <class name="elephant-hint"></class>
                                </style>
                                <property name="label">Waiting for elephant...</property>
                                <property name="hexpand">true</property>
                                <property name="vexpand">true</property>
                                <property name="visible">false</property>
                                <property name="valign">0.5</property>
                              </object>
                            </child>
                            <child>
                              <object class="GtkLabel" id="Placeholder">
                                <style>
                                  <class name="placeholder"></class>
                                </style>
                                <property name="label">No Results</property>
                                <property name="hexpand">true</property>
                                <property name="vexpand">true</property>
                                <property name="valign">0.5</property>
                              </object>
                            </child>
                            <child>
                              <object class="GtkScrolledWindow" id="Scroll">
                                <style>
                                  <class name="scroll"></class>
                                </style>
                                <property name="can_focus">false</property>
                                <property name="overlay-scrolling">true</property>
                                <property name="hexpand">true</property>
                                <property name="vexpand">true</property>
                                <property name="max-content-width">500</property>
                                <property name="min-content-width">500</property>
                                <property name="max-content-height">400</property>
                                <property name="propagate-natural-height">true</property>
                                <property name="propagate-natural-width">true</property>
                                <property name="hscrollbar-policy">automatic</property>
                                <property name="vscrollbar-policy">automatic</property>
                                <child>
                                  <object class="GtkGridView" id="List">
                                    <style>
                                      <class name="list"></class>
                                    </style>
                                    <property name="max_columns">1</property>
                                    <property name="min_columns">1</property>
                                    <property name="can_focus">false</property>
                                  </object>
                                </child>
                              </object>
                            </child>
                            <child>
                              <object class="GtkBox" id="Preview">
                                <style>
                                  <class name="preview"></class>
                                </style>
                              </object>
                            </child>
                          </object>
                        </child>
                        <child>
                          <object class="GtkBox" id="Keybinds">
                            <property name="hexpand">true</property>
                            <property name="margin-top">10</property>
                            <style>
                              <class name="keybinds"></class>
                            </style>
                            <child>
                              <object class="GtkBox" id="GlobalKeybinds">
                                <property name="spacing">10</property>
                                <style>
                                  <class name="global-keybinds"></class>
                                </style>
                              </object>
                            </child>
                            <child>
                              <object class="GtkBox" id="ItemKeybinds">
                                <property name="hexpand">true</property>
                                <property name="halign">end</property>
                                <property name="spacing">10</property>
                                <style>
                                  <class name="item-keybinds"></class>
                                </style>
                              </object>
                            </child>
                          </object>
                        </child>
                        <child>
                          <object class="GtkLabel" id="Error">
                            <style>
                              <class name="error"></class>
                            </style>
                            <property name="xalign">0</property>
                            <property name="visible">false</property>
                          </object>
                        </child>
                      </object>
                    </child>
                  </object>
                </child>
              </object>
            </interface>
          '';
          preview = ''
            <?xml version="1.0" encoding="UTF-8"?>
            <interface>
              <requires lib="gtk" version="4.0"></requires>
              <object class="GtkBox" id="PreviewBox">
                <style>
                  <class name="preview-box"></class>
                </style>
                <property name="height-request">300</property>
                <property name="width-request">500</property>
                <child>
                  <object class="GtkStack" id="PreviewStack">
                    <style>
                      <class name="preview-stack"></class>
                    </style>
                    <property name="hexpand">true</property>
                    <property name="vexpand">true</property>
                  </object>
                </child>
              </object>
            </interface>
          '';
        };
      };
    };
  };
}
