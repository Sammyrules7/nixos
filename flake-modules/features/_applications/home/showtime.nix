{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.showtime ];
  };
}
