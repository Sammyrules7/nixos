{ pkgs, inputs, ... }:

let
  webAppBrowser = "helium";
  browser = "zen-beta";

  webApps = [
    {
      name = "YouTube";
      url = "https://youtube.com";
      key = "Y";
      icon = "${inputs.dashboard-icons}/png/youtube.png";
    }
    {
      name = "GitHub";
      url = "https://github.com";
      key = "G";
      icon = "${inputs.dashboard-icons}/png/github.png";
    }
    {
      name = "Gemini";
      url = "https://gemini.google.com";
      key = "A";
      icon = "${inputs.dashboard-icons}/png/google-gemini.png";
    }
  ];

  mkDesktopEntry = app: {
    name = app.name;
    exec = "${webAppBrowser} --app=${app.url}";
    icon = app.icon;
    terminal = false;
    categories = [ "Network" "WebBrowser" ];
    type = "Application";
  };

  mkBind = app: "SUPER_SHIFT, ${app.key}, exec, ${webAppBrowser} --app=${app.url}";

in
{
  xdg.desktopEntries = builtins.listToAttrs (map (app: {
    name = app.name;
    value = mkDesktopEntry app;
  }) webApps);

  wayland.windowManager.hyprland.settings = {
    "$browser" = browser;
    "$webAppBrowser" = webAppBrowser;

    bind = [
      "SUPER_SHIFT, B, exec, $browser"
    ] ++ (map mkBind webApps);
  };
}
