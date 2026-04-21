{ config, lib, pkgs, ... }:

{
  options.features.sops.enable = lib.mkEnableOption "SOPS secrets management";

  config = lib.mkIf config.features.sops.enable {
    environment.systemPackages = [ pkgs.sops ];

    sops = {
      age.sshKeyPaths = [ "/home/sammy/.ssh/id_ed25519" ];
    };
  };
}
