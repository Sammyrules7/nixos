{ pkgs, lib, ... }:

{
  # wlsunset for seamless blue light transitions
  services.wlsunset = {
    enable = true;

    # Edmonton coordinates
    latitude = "53.5";
    longitude = "-113.5";

    # Temperature settings
    temperature = {
      day = 6500;
      night = 4000;
    };
  };

  # Override the service to include the transition duration (-d)
  # -d 7200 is 2 hours in seconds
  systemd.user.services.wlsunset.Service.ExecStart = lib.mkForce (
    "${pkgs.wlsunset}/bin/wlsunset -l 53.5 -L -113.5 -t 4000 -T 6500 -d 7200"
  );

  # Timer to "prime" wlsunset daily at midday.
  # This ensures it's running before sunset even if you turned it off earlier,
  # but allows you to toggle it off at night and have it STAY off until the next day.
  systemd.user.timers.wlsunset-ensure = {
    Unit.Description = "Ensure wlsunset is running for the day";
    Timer = {
      OnCalendar = "*-*-* 12:00:00"; # Every day at noon
      Unit = "wlsunset.service";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
