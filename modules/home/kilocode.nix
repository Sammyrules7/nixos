{ config, lib, ... }:

{
  options.features.kilocode-cli.enable = lib.mkEnableOption "kilocode CLI via npm";

  config = lib.mkIf config.features.kilocode-cli.enable {
  };
}