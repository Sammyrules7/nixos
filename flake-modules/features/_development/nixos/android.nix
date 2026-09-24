{ config, pkgs, ... }:

let
  androidPackages = pkgs.androidenv.composeAndroidPackages {
    includeEmulator = false;
    includeNDK = false;
    platformVersions = [
      "34"
      "35"
      "36"
      "latest"
    ];
    buildToolsVersions = [
      "34.0.0"
      "35.0.0"
      "36.1.0"
      "latest"
    ];
  };
  androidSdk = androidPackages.androidsdk;
  latestBuildTools = pkgs.lib.getVersion (builtins.head androidPackages.build-tools);
  studio = pkgs.symlinkJoin {
    name = "android-studio-with-sdk";
    paths = [ (pkgs.android-studio.withSdk androidSdk) ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/android-studio \
        --set GRADLE_OPTS "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdk}/libexec/android-sdk/build-tools/${latestBuildTools}/aapt2"
    '';
  };
in
{
  environment.systemPackages = with pkgs; [
    studio
    android-tools
    jdk
    scrcpy
    androidSdk
  ];

  environment.etc."android-sdk".source = "${androidSdk}/libexec/android-sdk";

  users.users.${config.workstation.user.name}.extraGroups = [ "adbusers" ];
  nixpkgs.config.android_sdk.accept_license = true;
}
