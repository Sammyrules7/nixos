{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.sops ];

  sops = {
    # System secrets are installed during initrd activation, before /home is
    # mounted. Use the persistent host key that is available at that point.
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };
}
