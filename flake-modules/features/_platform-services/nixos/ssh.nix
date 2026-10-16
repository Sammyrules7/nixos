{ config, pkgs, ... }:
{

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      ChallengeResponseAuthentication = false;
    };
  };

  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  environment.systemPackages = [ pkgs.ethtool ];

  # sammydesktop's tailscaled runs Tailscale's built-in SSH server on port 22
  # ("SSH-2.0-Tailscale" banner). Modern OpenSSH offers the post-quantum
  # mlkem768x25519-sha256 KEX first, which stalls there during key exchange.
  # Drop it so we agree on a classical KEX instead.
  programs.ssh.extraConfig = ''
    Host sammydesktop
      KexAlgorithms -mlkem768x25519-sha256
  '';

  users.users.${config.workstation.user.name}.openssh.authorizedKeys.keys = [
    # desktop
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICBbJZYAoaiso9r80YdbBkqFZ1bggET4EEkzZ9ckBbGW"
    # laptop
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICvbJQ3KnO165S9pyfQ5qHXFv51cw3LmsvUn6Xo2Bbr7"
  ];

  #services.fail2ban = {
  #  enable = true;
  #  maxretry = 3;
  #  bantime = "1d";
  #  ignoreIP = [
  #    "127.0.0.1/8"
  #    "::1"
  #  ];
  #};
}
