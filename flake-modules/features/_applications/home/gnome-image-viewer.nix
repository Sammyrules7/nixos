{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.loupe ];
  };
}
