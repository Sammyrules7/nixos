{ ... }:

{
  imports = [
    ../common
    ./hardware-configuration.nix
  ];

  networking.hostName = "Sammy_Laptop";

  home-manager.users.sammy = {
    imports = [
      ./displays.nix
    ];
    wayland.windowManager.hyprland.settings.input.sensitivity = 0.3;
  };
}
