{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  environment.systemPackages = with pkgs; [
    gcc
    go
    gopls
    gotools
  ];
}
