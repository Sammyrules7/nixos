{ inputs, ... }:

{
  flake.modules.homeManager.agent-tools =
    {
      pkgs,
      ...
    }:
    {
      home.packages = [
        pkgs.codex
        pkgs.t3code
      ];
    };
}
