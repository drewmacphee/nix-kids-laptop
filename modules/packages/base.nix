{ config, pkgs, ... }:

{
  # Base packages for all users
  home.packages = with pkgs; [
    google-chrome
    vlc
    libreoffice
    gimp
  ];
}
