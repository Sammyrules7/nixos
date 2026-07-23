{ config, ... }:

let
  modules = config.flake.modules;
in
{
  flake.modules = {
    nixos.workstation = {
      imports = [
        modules.nixos.integrations
        modules.nixos.foundation
        modules.nixos.platform-services
        modules.nixos.development
        modules.nixos.desktop-environment
        modules.nixos.gaming
        modules.nixos.user-sammy
      ];
    };

    homeManager.workstation = {
      imports = [
        modules.homeManager.applications
        modules.homeManager.agent-tools
        modules.homeManager.development
        modules.homeManager.desktop-environment
        modules.homeManager.gaming
      ];

      home.stateVersion = "25.11";
      programs.home-manager.enable = true;
    };
  };
}
