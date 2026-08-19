{
  pkgs,
  inputs,
  lib,
  ...
}:

let
  webAppBrowser = "zen-beta";
  browser = "zen-beta";
  lua = import ./lua.nix { inherit lib; };
  exec = command: lua.dispatcher "exec_cmd" command;

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
    exec = "${webAppBrowser} --kiosk --blank-window ${app.url}";
    icon = app.icon;
    terminal = false;
    categories = [
      "Network"
      "WebBrowser"
    ];
    type = "Application";
  };

  mkBind =
    app:
    lua.bind "SUPER + SHIFT + ${app.key}" (exec "${webAppBrowser} --kiosk --blank-window ${app.url}");

in
{
  programs.zen-browser.profiles.default.userChrome = ''
    /* Blank web-app windows should contain only the page itself. */
    :root[zen-unsynced-window="true"] #navigator-toolbox {
      display: none !important;
    }
  '';

  xdg.desktopEntries = builtins.listToAttrs (
    map (app: {
      name = app.name;
      value = mkDesktopEntry app;
    }) webApps
  );

  wayland.windowManager.hyprland.settings = {
    bind = [
      (lua.bind "SUPER + SHIFT + B" (exec browser))
    ]
    ++ (map mkBind webApps);
  };
}
