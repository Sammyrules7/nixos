{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:denful/import-tree";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    helium.url = "github:schembriaiden/helium-browser-nix-flake";

    stylix.url = "github:nix-community/stylix";

    elephant.url = "github:abenz1267/elephant";
    walker = {
      url = "github:abenz1267/walker";
      inputs.elephant.follows = "elephant";
    };

    dashboard-icons = {
      url = "github:homarr-labs/dashboard-icons";
      flake = false;
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    sopsnix.url = "github:Mic92/sops-nix";
    sopsnix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      flake-parts,
      import-tree,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        flake-parts.flakeModules.modules
        (import-tree ./flake-modules)
      ];
    };
}
