{ ... }:

{
  flake.modules.homeManager.applications = {
    imports = [
      ./_applications/home/btop.nix
      ./_applications/home/file-roller.nix
      ./_applications/home/fish.nix
      ./_applications/home/ghostty.nix
      ./_applications/home/gnome-files.nix
      ./_applications/home/gnome-image-viewer.nix
      ./_applications/home/showtime.nix
      ./_applications/home/vesktop.nix
      ./_applications/home/voxtype.nix
    ];
  };
}
