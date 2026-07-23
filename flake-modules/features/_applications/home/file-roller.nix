{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.file-roller ];
  };
}
