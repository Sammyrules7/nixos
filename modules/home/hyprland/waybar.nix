{ pkgs, lib, ... }:

{
  stylix.targets.waybar.enable = lib.mkForce false;

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 32;
        spacing = 8;
        margin-top = 6;
        margin-left = 10;
        margin-right = 10;

        modules-left = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "custom/weather" "clock" ];
        modules-right = [ "custom/mako" "pulseaudio" "bluetooth" "network" "cpu" "memory" "temperature" "backlight" "power-profiles-daemon" "battery" "tray" ];

        "custom/mako" = {
          interval = 1;
          return-type = "json";
          exec = pkgs.writeShellScript "mako-status" ''
            mode=$(makoctl mode)
            if echo "$mode" | grep -q "do-not-disturb"; then
              echo '{"text": "󰂛", "tooltip": "Do Not Disturb", "class": "dnd"}'
            else
              echo '{"text": "", "class": "none"}'
            fi
          '';
          on-click = "makoctl mode -t do-not-disturb";
        };

        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          active-only = false;
          on-click = "activate";
          format = "{name}";
        };

        "hyprland/window" = {
          format = "{title}";
          max-length = 30;
          separate-outputs = true;
          rewrite = {
            "" = "󰇄  Workspace";
          };
        };

        "custom/weather" = {
          format = "{}";
          tooltip = true;
          interval = 900;
          exec = pkgs.writeShellScript "weather" ''
            weather=$(curl -s "wttr.in/?format=%c+%t" | tr -s ' ' | xargs)
            if [ -n "$weather" ]; then
              echo "$weather"
            else
              echo "󰖐"
            fi
          '';
        };

        "tray" = {
          spacing = 10;
        };

        "clock" = {
          format = "{:%I:%M %p}";
          format-alt = "󰃭  {:%A, %B %d, %Y (%I:%M %p)}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
        };

        "cpu" = {
          interval = 1;
          format = "  {usage}%";
          format-alt = "  {usage}% ({avg_frequency}GHz)";
          tooltip = true;
        };

        "memory" = {
          interval = 1;
          format = "󰍛  {used:0.1f}G";
          format-alt = "󰍛  {used:0.1f}G/{total:0.1f}G";
          tooltip = true;
        };

        "temperature" = {
          interval = 1;
          critical-threshold = 80;
          format = "{icon}  {temperatureC}°C";
          format-icons = [ "" "" "" ];
        };

        "backlight" = {
          format = "{icon}  {percent}%";
          format-icons = [ "" "" "" "" "" "" "" "" "" ];
        };

        "battery" = {
          interval = 10;
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon}  {capacity}%";
          format-charging = "󱐋  {capacity}%";
          format-plugged = "  {capacity}%";
          format-alt = "{icon}  {time}";
          format-icons = [ "󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        };

        "power-profiles-daemon" = {
          format = "{icon}";
          tooltip-format = "Power profile: {profile}\nDriver: {driver}";
          tooltip = true;
          format-icons = {
            default = "󰓅";
            performance = "󰓅";
            balanced = "󰾗";
            power-saver = "󰌪";
          };
        };

        "network" = {
          interval = 5;
          format-wifi = "󰤨  {essid}";
          format-ethernet = "󰈀  {ipaddr}";
          format-disconnected = "󰤮  Disconnected"; 
          tooltip-format = "{ifname} via {gwaddr} 󰈀";
          format-alt = "󰤨  {signalStrength}%";
        };

        "pulseaudio" = {
          format = "{icon}  {volume}%";
          format-bluetooth = "{icon}  {volume}%";
          format-muted = "󰝟  Muted"; 
          format-icons = {
            headphone = "";
            hands-free = "󰂑";
            headset = "󰂑";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" "" ];
          };
          on-click = "pavucontrol";
        };

        "bluetooth" = {
          format = "  {status}";
          format-connected = "  {device_alias}";
          format-connected-battery = "  {device_alias} {device_battery_percentage}%";
          format-device-disconnected = "󰂲  {status}";
          format-disabled = "󰂲  Disabled"; 
          format-off = "󰂲  Off";      
          on-click = "blueman-manager";
        };
      };
    };
    style = ''
      * {
          border: none;
          font-family: "JetBrainsMono Nerd Font Mono";
          font-size: 15px;
          font-weight: normal;
          min-height: 0;
      }

      window#waybar {
          background-color: transparent;
      }

      /* Pebble styling for modules with localized blur */
      #window,
      #clock,
      #custom-weather,
      #custom-mako,
      #pulseaudio,
      #bluetooth,
      #network,
      #cpu,
      #memory,
      #temperature,
      #backlight,
      #battery,
      #power-profiles-daemon,
      #tray {
          background-color: rgba(255, 255, 255, 0.01); 
          color: #ffffff;
          border-radius: 12px;
          padding: 0 12px;
          margin: 4px 3px;
          border: 1px solid rgba(255, 255, 255, 0.05);
          min-height: 28px;
      }

      #custom-mako.none {
          background-color: transparent;
          border: none;
          padding: 0;
          margin: 0;
          min-height: 0;
      }

      /* Clean, outline-free workspace selector */
      #workspaces {
          background-color: rgba(255, 255, 255, 0.01); 
          color: #ffffff;
          border-radius: 12px;
          padding: 0 2px;
          margin: 4px 3px;
          border: none;
          box-shadow: none;
      }

      #workspaces button {
          padding: 0 6px;
          color: #ffffff;
          border-radius: 10px;
          margin: 3px 1px;
          transition: all 0.2s ease;
          font-size: 15px;
          border: none;
          outline: none;
          box-shadow: none;
          min-width: 24px;
      }

      #workspaces button.active {
          background-color: rgba(255, 255, 255, 0.1);
          color: #ffffff;
          border: none;
          box-shadow: none;
      }

      #workspaces button.urgent {
          background-color: #eb4d4b;
          animation: blink 0.5s infinite alternate;
      }

      @keyframes blink {
          to {
              background-color: #ff7675;
          }
      }

      #window {
          font-weight: bold;
      }

      #battery.critical:not(.charging) {
          color: #e74c3c;
          animation: blink 0.5s infinite alternate;
      }

      #tray {
          margin-right: 0;
      }
    '';
  };
}
