{ config, lib, pkgs, ... }:

{
  options.features.swayosd.enable = lib.mkEnableOption "SwayOSD system-level configuration";

  config = lib.mkIf config.features.swayosd.enable {
    # System-wide udev rules and polkit for brightness/input access
    services.udev.packages = [ pkgs.swayosd ];
    security.polkit.enable = true;
    
    # DBus service for SwayOSD
    services.dbus.packages = [ pkgs.swayosd ];

    # Add the necessary groups to the system
    users.groups.video = { };
    users.groups.input = { };

    # The package itself
    environment.systemPackages = [ pkgs.swayosd ];

    # Optional: libinput backend if needed (some hardware requires it for CAPS LOCK etc)
    # systemd.packages = [ pkgs.swayosd ];
  };
}
