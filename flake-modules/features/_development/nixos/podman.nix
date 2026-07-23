{
  config,
  lib,
  pkgs,
  ...
}:

{
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  users.users.${config.workstation.user.name} = {
    extraGroups = [
      "podman"
    ];
  };
}
