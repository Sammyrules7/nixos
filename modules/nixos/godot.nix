{
  config,
  lib,
  pkgs,
  ...
}:

let
  myAndroidSdk =
    (pkgs.androidenv.composeAndroidPackages {
      buildToolsVersions = [ "34.0.0" ];
      platformVersions = [
        "34"
        "35"
      ];
      includeEmulator = false;
      includeNDK = false;
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
