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
        modules-right = [ "pulseaudio" "bluetooth" "network" "cpu" "memory" "temperature" "backlight" "power-profiles-daemon" "battery" "tray" ];

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
            "" = "Workspace";
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
          format = "<span size='17000' rise='-2000'>󱑎</span> {:%I:%M %p}";
          format-alt = "<span size='17000' rise='-2000'>󰃭</span> {:%A, %B %d, %Y (%I:%M %p)}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
        };

        "cpu" = {
          interval = 1;
          format = "<span size='17000' rise='-2000'></span> {usage}%";
          format-alt = "<span size='17000' rise='-2000'></span> {usage}% ({avg_frequency}GHz)";
          tooltip = true;
        };

        "memory" = {
          interval = 1;
          format = "<span size='17000' rise='-2000'>󰍛</span> {used:0.1f}G";
          format-alt = "<span size='17000' rise='-2000'>󰍛</span> {used:0.1f}G/{total:0.1f}G";
          tooltip = true;
        };

        "temperature" = {
          interval = 1;
          critical-threshold = 80;
          format = "<span size='17000' rise='-2000'>{icon}</span> {temperatureC}°C";
          format-icons = [ "" "" "" ];
        };

        "backlight" = {
          format = "<span size='17000' rise='-2000'>{icon}</span> {percent}%";
          format-icons = [ "" "" "" "" "" "" "" "" "" ];
        };

        "battery" = {
          interval = 10;
          states = {
            warning = 30;
            critical = 15;
          };
          format = "<span size='17000' rise='-2000'>{icon}</span> {capacity}%";
          format-charging = "<span size='17000' rise='-2000'>󱐋</span> {capacity}%";
          format-plugged = "<span size='17000' rise='-2000'></span> {capacity}%";
          format-alt = "<span size='17000' rise='-2000'>{icon}</span> {time}";
          format-icons = [ "󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        };

        "power-profiles-daemon" = {
          format = "<span size='17000' rise='-2000'>{icon}</span>";
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
          format-wifi = "<span size='17000' rise='-2000'>󰤨</span> {essid}";
          format-ethernet = "<span size='17000' rise='-2000'>󰈀</span> {ipaddr}";
          format-disconnected = ""; 
          tooltip-format = "{ifname} via {gwaddr} 󰈀";
          format-alt = "<span size='17000' rise='-2000'>󰤨</span> {signalStrength}%";
        };

        "pulseaudio" = {
          format = "<span size='17000' rise='-2000'>{icon}</span> {volume}%";
          format-bluetooth = "<span size='17000' rise='-2000'>{icon}</span> {volume}%";
          format-muted = ""; 
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
          format = "<span size='17000' rise='-2000'></span> {status}";
          format-connected = "<span size='17000' rise='-2000'></span> {device_alias}";
          format-connected-battery = "<span size='17000' rise='-2000'></span> {device_alias} {device_battery_percentage}%";
          format-device-disconnected = "";
          format-disabled = ""; 
          format-off = "";      
          on-click = "blueman-manager";
        };
      };
    };
    style = ''
      * {
          border: none;
          font-family: "JetBrainsMono Nerd Font Mono";
          font-size: 13px;
      }

      window#waybar {
          background-color: transparent;
      }

      /* Pebble styling for modules with localized blur */
      #window,
      #clock,
      #custom-weather,
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
      }

      /* Clean, outline-free workspace selector */
      #workspaces {
          background-color: rgba(255, 255, 255, 0.01); 
          color: #ffffff;
          border-radius: 12px;
          padding: 0 4px;
          margin: 4px 3px;
          border: none;
          box-shadow: none;
      }

      #workspaces button {
          padding: 0 8px;
          color: #ffffff;
          border-radius: 10px;
          margin: 3px 2px;
          transition: all 0.2s ease;
          font-size: 18px;
          border: none;
          outline: none;
          box-shadow: none;
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

      #cpu, #memory {
          font-family: "JetBrainsMono Nerd Font Mono";
      }

      #tray {
          margin-right: 0;
      }
    '';
  };

  wayland.windowManager.hyprland.settings = {
    layerrule = [
      "blur on, match:namespace waybar"
      "xray off, match:namespace waybar"
      "ignore_alpha 0.005, match:namespace waybar"
    ];
  };
}
