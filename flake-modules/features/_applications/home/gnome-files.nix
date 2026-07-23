{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.nautilus ];
  };
}
