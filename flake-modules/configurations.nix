{
  config,
  inputs,
  ...
}:

let
  mkWorkstation =
    hostModule:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        config.flake.modules.nixos.workstation
        hostModule
      ];
    };
in
{
  flake.nixosConfigurations = {
    Desktop = mkWorkstation config.flake.modules.nixos.desktop-host;
    Laptop = mkWorkstation config.flake.modules.nixos.laptop-host;
  };
}
