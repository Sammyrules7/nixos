{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = [ pkgs.sops ];

  sops = {
    age.sshKeyPaths = [ "${config.workstation.user.homeDirectory}/.ssh/id_ed25519" ];
  };
}
