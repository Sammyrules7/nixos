{ ... }:

{
  flake.modules = {
    nixos.development = {
      imports = [
        ./_development/nixos/dev.nix
        ./_development/nixos/godot.nix
        ./_development/nixos/podman.nix
      ];
    };

    homeManager.development = {
      imports = [
        ./_development/home/git.nix
        ./_development/home/godot.nix
        ./_development/home/kubernetes
        ./_development/home/wakatime/wakatime.nix
        ./_development/home/zed.nix
        ./_development/home/worktree-tool.nix
      ];
    };
  };
}
