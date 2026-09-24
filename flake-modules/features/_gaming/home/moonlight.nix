{
  config,
  lib,
  pkgs,
  ...
}:

let
  defaults = pkgs.writeText "moonlight-defaults.json" (
    builtins.toJSON config.features.moonlight.settings
  );
  configure = pkgs.writeText "configure-moonlight.py" ''
    import configparser
    import json
    import os
    import pathlib
    import sys
    import tempfile

    path = pathlib.Path(sys.argv[1])
    path.parent.mkdir(parents=True, exist_ok=True)
    settings = configparser.ConfigParser(interpolation=None, strict=False)
    settings.optionxform = str
    settings.read(path)
    if not settings.has_section("General"):
        settings.add_section("General")
    with open(sys.argv[2]) as source:
        for key, value in json.load(source).items():
            settings.set("General", key, str(value).lower() if isinstance(value, bool) else str(value))
    # Keep Qt's certificate, private key and paired-host sections intact.
    with tempfile.NamedTemporaryFile(mode="w", dir=path.parent, delete=False) as target:
        settings.write(target, space_around_delimiters=False)
    os.replace(target.name, path)
  '';
in
{
  options.features.moonlight.settings = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.oneOf [
        lib.types.bool
        lib.types.int
        lib.types.str
      ]
    );
    description = "Moonlight Qt preferences merged on activation without replacing pairing data.";
    default = { };
  };

  config = {
    features.moonlight.settings = {
      defaultver = lib.mkDefault 2;
      width = lib.mkDefault 1920;
      height = lib.mkDefault 1080;
      fps = lib.mkDefault 60;
      bitrate = lib.mkDefault 30000;
      # Moonlight 6: 2 = HEVC; 1 = hardware decoding; 0 = fullscreen/stereo.
      videocfg = lib.mkDefault 2;
      videodec = lib.mkDefault 1;
      windowmode = lib.mkDefault 0;
      audiocfg = lib.mkDefault 0;
      vsync = lib.mkDefault true;
      framepacing = lib.mkDefault true;
      keepawake = lib.mkDefault true;
      hostaudio = lib.mkDefault false;
      hdr = lib.mkDefault false;
      yuv444 = lib.mkDefault false;
      quitAppAfter = lib.mkDefault false;
      # Leave room for the encrypted Tailscale tunnel at its 1280-byte MTU.
      packetsize = lib.mkDefault 1024;
    };

    home.activation.moonlightDefaults = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${pkgs.python3}/bin/python ${configure} \
        ${lib.escapeShellArg "${config.xdg.configHome}/Moonlight Game Streaming Project/Moonlight.conf"} \
        ${defaults}
    '';
  };
}
