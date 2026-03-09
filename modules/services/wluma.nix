{ pkgs, ... }:

{
  boot.kernelModules = [ "hid-sensor-hub" ];

  hardware.sensor.iio.enable = true;
  hardware.acpilight.enable = true;

  systemd.services.wluma-resume = {
    description = "Restart wluma after resume to fix ambient light sensor bug";
    after = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" "suspend-then-hibernate.target" ];
    wantedBy = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" "suspend-then-hibernate.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/sleep 3; ${pkgs.systemd}/bin/systemctl restart iio-sensor-proxy.service; ${pkgs.sudo}/bin/sudo -u sammy XDG_RUNTIME_DIR=/run/user/1000 ${pkgs.systemd}/bin/systemctl --user restart wluma.service || true'";
    };
  };

  home-manager.users.sammy = {
    home.packages = [ pkgs.wluma ];

    xdg.configFile."wluma/config.toml".text = ''
      [als.iio]
      path = "/sys/bus/iio/devices"
      thresholds = { 0 = "night", 15 = "dark", 30 = "dim", 45 = "normal", 60 = "bright", 75 = "outdoors" }

      [[output.backlight]]
      name = "eDP-1"
      path = "/sys/class/backlight/amdgpu_bl1"
      capturer = "wayland"

      [[output.backlight]]
      name = "framework_laptop"
      path = "/sys/class/leds/framework_laptop::kbd_backlight"
      capturer = "none"
    '';

    systemd.user.services.wluma = {
      Unit = {
        Description = "Automatic brightness based on screen content and ambient light";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${pkgs.wluma}/bin/wluma";
        Restart = "on-failure";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
