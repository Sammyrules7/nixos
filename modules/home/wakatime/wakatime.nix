# modules/home/wakatime/default.nix
{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:

{
  home.packages = [ pkgs.wakatime-cli ];

  programs.zed-editor.extensions = [
    "wakatime"
  ];

  sops = {
    defaultSopsFile = ./apikey.enc.yaml;
    age.sshKeyPaths = [ "/home/sammy/.ssh/id_ed25519" ];
    secrets.wakatime_api_key = {
      sopsFile = ./apikey.enc.yaml;
      path = "/run/user/${toString osConfig.users.users.sammy.uid}/secrets/wakatime_api_key";
    };
  };

  home.file.".wakatime.cfg".text = ''
    [settings]
    api_key_vault_cmd = cat ${config.sops.secrets.wakatime_api_key.path}

    status_bar_enabled = true
    status_bar_coding_activity = true
  '';
}
