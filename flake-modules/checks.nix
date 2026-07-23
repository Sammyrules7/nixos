{ config, ... }:

{
  systems = [ "x86_64-linux" ];

  perSystem =
    { pkgs, ... }:
    {
      checks = {
        desktop = config.flake.nixosConfigurations.Desktop.config.system.build.toplevel;
        laptop = config.flake.nixosConfigurations.Laptop.config.system.build.toplevel;
      };

      formatter = pkgs.nixfmt;
    };
}
