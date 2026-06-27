{
  config,
  lib,
  pkgs,
  ...
}:

let
  myAndroidSdk =
    (pkgs.androidenv.composeAndroidPackages {
      includeEmulator = false;
      includeNDK = false;
      platformVersions = [
        "34"
        "35"
        "36"
      ];
      buildToolsVersions = [
        "34.0.0"
        "35.0.0"
        "36.1.0"
      ];
    }).androidsdk;
in
{
  environment.systemPackages = with pkgs; [
    android-tools
    jdk
    scrcpy
    myAndroidSdk
  ];

  environment.etc."android-sdk".source = "${myAndroidSdk}/libexec/android-sdk";

  users.users.sammy.extraGroups = [ "adbusers" ];
  nixpkgs.config.android_sdk.accept_license = true;
}
