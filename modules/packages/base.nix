{ config, pkgs, ... }:

{
  # Base packages for all users
  home.packages = with pkgs; [
    gawk
    (google-chrome.override {
      commandLineArgs = [
        "--disable-gpu"
        "--ozone-platform=x11"
      ];
    })
    vlc
    libreoffice
    gimp
  ];
}
