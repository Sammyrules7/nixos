{ config, lib, pkgs, osConfig, inputs, ... }:

{
  options.features.kubernetes.enable = lib.mkEnableOption "Kubernetes tools and kubeconfig";

  config = lib.mkIf config.features.kubernetes.enable {
    home.packages = with pkgs; [
      kubectl
      kubecolor
      fluxcd
      kubernetes-helm
      k9s
    ];

    home.shellAliases = {
      kubectl = "kubecolor";
    };

    xdg.configFile."k9s/k9s.yaml".source = ./k9s.yaml;

    xdg.desktopEntries.k9s = {
      name = "k9s";
      exec = "k9s";
      icon = "${inputs.dashboard-icons}/png/kubernetes.png";
      terminal = false;
      categories = [ "X-Kubernetes" "Development" "System" ];
      type = "Application";
      comment = "Kubernetes CLI management tool";
    };

    sops = {
      defaultSopsFile = ./config.enc.yaml;
      age.sshKeyPaths = [ "/home/sammy/.ssh/id_ed25519" ];

      secrets.kubeconfig = {
        sopsFile = ./config.enc.yaml;
        path = "/run/user/${toString osConfig.users.users.sammy.uid}/secrets/kubeconfig";
      };
    };

    home.sessionVariables = {
      KUBECONFIG = config.sops.secrets.kubeconfig.path;
    };
  };
}
