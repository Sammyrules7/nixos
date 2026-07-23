{ ... }:

{
  flake.modules.nixos = {
    desktop-host = ../hosts/desktop;
    laptop-host = ../hosts/laptop;
  };
}
