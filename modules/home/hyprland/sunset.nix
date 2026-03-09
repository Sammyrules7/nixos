{ pkgs, lib, ... }:

{
  # wlsunset for seamless blue light transitions
  services.wlsunset = {
    enable = true;
    
    # Start fading at 20:00 (8 PM) and finish at 22:00 (10 PM)
    # Note: wlsunset uses sunset/sunrise or lat/long. 
    # For fixed times, we can use the sunset/sunrise parameters.
    sunset = "22:00"; 
    sunrise = "07:00";
    
    # Transition duration in minutes (2 hours = 120 minutes)
    # Note: wlsunset's -d flag sets the duration of the transition.
    # It starts transitioning -d minutes BEFORE the sunset time.
  };

  # We'll override the systemd service to add the duration flag for the fade
  systemd.user.services.wlsunset.Service.ExecStart = lib.mkForce (
    "${pkgs.wlsunset}/bin/wlsunset -S 07:00 -s 22:00 -d 120 -t 4000 -T 6500"
  );
}
