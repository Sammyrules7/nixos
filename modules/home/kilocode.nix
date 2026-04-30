{ config, lib, ... }:

let
  kiloConfig = {
    "$schema" = "https://app.kilo.ai/config.json";
    permission = {
      bash = {
        "*" = "allow";
        #"git push *" = "ask";
        "git force-push *" = "ask";
        "git reset *" = "ask";
        "git checkout --force *" = "ask";
        "git clean -fd *" = "ask";
        "git rebase -i *" = "ask";
        "git commit --amend *" = "ask";
      };
      read = "allow";
      edit = "allow";
      glob = "allow";
      grep = "allow";
      list = "allow";
      task = "allow";
      webfetch = "allow";
      websearch = "allow";
      codesearch = "allow";
      todowrite = "allow";
      todoread = "allow";
      question = "allow";
      skill = "allow";
      external_directory = "allow";
    };
  };
in

{
  options.features.kilocode-cli.enable = lib.mkEnableOption "kilocode CLI via npm";

  config = lib.mkIf config.features.kilocode-cli.enable {
    xdg.configFile."kilo/kilo.json".text = builtins.toJSON kiloConfig;
  };
}
