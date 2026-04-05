{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.features.kilocode-cli.enable = lib.mkEnableOption "kilocode CLI via npm";

  config = lib.mkIf config.features.kilocode-cli.enable {
    environment.systemPackages = with pkgs; [
      steam-run
      nodejs
    ];

    programs.bash.shellInit = ''
      kilo() {
        steam-run npx @kilocode/cli "$@"
      }
    '';

    programs.zsh.shellInit = ''
      kilo() {
        steam-run npx @kilocode/cli "$@"
      }
    '';

    programs.fish.shellInit = ''
      function kilo
        steam-run npx @kilocode/cli $argv
      end
    '';
  };
}
