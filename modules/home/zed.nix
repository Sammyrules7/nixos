{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.features.zed = {
    enable = lib.mkEnableOption "Zed editor configuration";
    assistantModel = lib.mkOption {
      type = lib.types.str;
      default = "qwen2.5-coder:7b";
      description = "Model to use for the Zed assistant";
    };
    inlineModel = lib.mkOption {
      type = lib.types.str;
      default = "qwen2.5-coder:1.5b";
      description = "Model to use for inline completions (autocomplete)";
    };
  };

  config = lib.mkIf config.features.zed.enable {
    programs.zed-editor = {
      enable = true;
      userSettings = lib.mkForce {
        git = {
          inline_blame = {
            show_commit_summary = true;
          };
        };
        project_panel = {
          hide_root = true;
        };
        tabs = {
          git_status = true;
        };
        prettier = {
          allowed = true;
        };
        middle_click_paste = false;
        inlay_hints = {
          enabled = true;
        };
        minimap = {
          max_width_columns = 80;
          display_in = "all_editors";
          show = "auto";
        };
        git_panel = {
          tree_view = true;
        };
        agent = {
          notify_when_agent_waiting = "all_screens";
          show_turn_stats = true;
          favorite_models = [ ];
          model_parameters = [ ];
          tool_permissions = {
            default = "allow";
            tools = { };
          };
        };
        show_edit_predictions = true;
        edit_predictions = {
          mode = "eager";
          provider = "ollama";
          ollama = {
            api_url = "http://localhost:11434";
            model = config.features.zed.inlineModel;
          };
        };

        theme = "Glassy";

        language_models = {
          ollama = {
            api_url = "http://localhost:11434/api";
          };
        };
        assistant = {
          version = "2";
          default_model = {
            provider = "ollama";
            model = config.features.zed.assistantModel;
          };
        };
      };
      extensions = [
        "nix"
        "git-firefly"
      ];
    };

    # Install the custom theme
    home.file.".config/zed/themes/glassy.json".text = builtins.toJSON {
      name = "Glassy";
      author = "Sammy Scott (Based on Transparent Prism Collection by Magnus Pladsen (based on Zedokai by slymax))";
      themes = [
        {
          name = "Glassy";
          appearance = "dark";
          style = {
            background = "#00000000";
            "background.appearance" = "blurred";
            border = "#ffffff15";
            "border.disabled" = "#131313";
            "border.focused" = "#69676c";
            "border.selected" = "#131313";
            "border.transparent" = "#131313";
            "border.variant" = "#ffffff10";
            conflict = "#fd9353";
            created = "#7bd88f";
            deleted = "#fc618d";
            "drop_target.background" = "#ffffff08";
            "editor.active_line.background" = "#ffffff12";
            "editor.active_line_number" = "#f7f1ff";
            "editor.active_wrap_guide" = "#131313";
            "editor.background" = "#00000000";
            "editor.document_highlight.read_background" = "#383838";
            "editor.foreground" = "#f7f1ff";
            "editor.gutter.background" = "#00000000";
            "editor.line_number" = "#525053";
            "editor.subheader.background" = "#1c1c1c80";
            "editor.wrap_guide" = "#0f0f0f";
            "element.background" = "#36353780";
            "element.hover" = "#ffffff15";
            "element.selected" = "#ffffff20";
            "elevated_surface.background" = "#12121290";
            error = "#fc618d";
            "error.background" = "#1c1c1c80";
            "error.border" = "#0f0f0f";
            "ghost_element.hover" = "#ffffff12";
            "ghost_element.selected" = "#ffffff22";
            hidden = "#8b888f";
            hint = "#8b888f";
            "hint.background" = "#1a1a1a80";
            "hint.border" = "#0f0f0f";
            ignored = "#525053";
            info = "#fce566";
            "info.background" = "#1c1c1c80";
            "info.border" = "#0f0f0f";
            "link_text.hover" = "#f7f1ff";
            modified = "#fd9353";
            "pane_group.border" = "#ffffff10";
            "panel.background" = "#00000000";
            "panel.focused_border" = "#5ad4e640";
            players = [
              {
                background = "#f7f1ff";
                cursor = "#f7f1ff";
                selection = "#f7f1ff1a";
              }
              {
                background = "#fc618d";
                cursor = "#fc618d";
                selection = "#fc618d1a";
              }
              {
                background = "#7bd88f";
                cursor = "#7bd88f";
                selection = "#7bd88f1a";
              }
              {
                background = "#fd9353";
                cursor = "#fd9353";
                selection = "#fd93531a";
              }
              {
                background = "#fce566";
                cursor = "#fce566";
                selection = "#fce5661a";
              }
              {
                background = "#948ae3";
                cursor = "#948ae3";
                selection = "#948ae31a";
              }
              {
                background = "#5ad4e6";
                cursor = "#5ad4e6";
                selection = "#5ad4e61a";
              }
            ];
            predictive = "#8b888f";
            "scrollbar.thumb.background" = "#ffffff15";
            "scrollbar.thumb.border" = "#ffffff10";
            "scrollbar.thumb.hover_background" = "#ffffff26";
            "scrollbar.track.background" = "#00000000";
            "scrollbar.track.border" = "#00000000";
            "search.match_background" = "#383838";
            "status_bar.background" = "#00000000";
            "surface.background" = "#ffffff01";
            syntax = {
              attribute = {
                color = "#5ad4e6";
                font_style = "italic";
              };
              boolean = {
                color = "#948ae3";
              };
              comment = {
                color = "#69676c";
                font_style = "italic";
              };
              "comment.doc" = {
                color = "#69676c";
                font_style = "italic";
              };
              constant = {
                color = "#948ae3";
              };
              constructor = {
                color = "#fc618d";
              };
              emphasis = {
                font_style = "italic";
              };
              "emphasis.strong" = {
                font_weight = 700;
              };
              function = {
                color = "#7bd88f";
              };
              keyword = {
                color = "#fc618d";
              };
              label = {
                color = "#7bd88f";
              };
              link_text = {
                color = "#fc618d";
              };
              link_uri = {
                color = "#7bd88f";
              };
              number = {
                color = "#948ae3";
              };
              operator = {
                color = "#fc618d";
              };
              preproc = {
                color = "#948ae3";
              };
              property = {
                color = "#f7f1ff";
              };
              punctuation = {
                color = "#8b888f";
              };
              "punctuation.bracket" = {
                color = "#8b888f";
              };
              "punctuation.delimiter" = {
                color = "#8b888f";
              };
              "punctuation.list_marker" = {
                color = "#8b888f";
              };
              "punctuation.special" = {
                color = "#8b888f";
              };
              string = {
                color = "#fce566";
              };
              "string.escape" = {
                color = "#f7f1ff";
              };
              "string.regex" = {
                color = "#fce566";
              };
              "string.special" = {
                color = "#fd9353";
              };
              "string.special.symbol" = {
                color = "#fd9353";
              };
              tag = {
                color = "#fc618d";
              };
              "text.literal" = {
                color = "#fce566";
              };
              title = {
                color = "#fce566";
              };
              type = {
                color = "#5ad4e6";
              };
              variable = {
                color = "#f7f1ff";
              };
              "variable.special" = {
                color = "#bab6c0";
                font_style = "italic";
              };
            };
            "tab.active_background" = "#ffffff12";
            "tab.inactive_background" = "#00000000";
            "tab_bar.background" = "#00000000";
            "terminal.ansi.black" = "#363537";
            "terminal.ansi.blue" = "#fd9353";
            "terminal.ansi.bright_black" = "#69676c";
            "terminal.ansi.bright_blue" = "#fd9353";
            "terminal.ansi.bright_cyan" = "#5ad4e6";
            "terminal.ansi.bright_green" = "#7bd88f";
            "terminal.ansi.bright_magenta" = "#948ae3";
            "terminal.ansi.bright_red" = "#fc618d";
            "terminal.ansi.bright_white" = "#f7f1ff";
            "terminal.ansi.bright_yellow" = "#fce566";
            "terminal.ansi.cyan" = "#5ad4e6";
            "terminal.ansi.green" = "#7bd88f";
            "terminal.ansi.magenta" = "#948ae3";
            "terminal.ansi.red" = "#fc618d";
            "terminal.ansi.white" = "#f7f1ff";
            "terminal.ansi.yellow" = "#fce566";
            "terminal.background" = "#00000000";
            text = "#f7f1ff";
            "text.accent" = "#fce566";
            "text.muted" = "#8b888f";
            "title_bar.background" = "#00000000";
            "title_bar.inactive_background" = "#00000000";
            "toolbar.background" = "#00000000";
            warning = "#fd9353";
            "warning.background" = "#1c1c1c80";
            "warning.border" = "#0f0f0f";
            "editor.indent_guide" = "#3a3a3a1a";
            "editor.indent_guide_active" = "#5a5a5a33";
            "editor.selection.background" = "#ffffff15";
            "editor.selection.focused_background" = "#ffffff20";
            "panel.indent_guide" = "#3a3a3a12";
            "panel.indent_guide_hover" = "#3a3a3a16";
            "panel.indent_guide_active" = "#3a3a3a1a";
            "ghost_element.background" = "#1a1a1a08";
            "ghost_element.active" = "#2a2a2a18";
            "editor.highlighted_line.background" = "#2a2a2a20";
          };
        }
      ];
    };
  };
}
