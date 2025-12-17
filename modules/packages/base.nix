{ config, pkgs, ... }:

{
  # Base packages for all users
  home.packages = with pkgs; [
    vlc
    libreoffice
    gimp
  ];
  
  # Google Chrome with proper configuration
  programs.chromium = {
    enable = true;
    package = pkgs.google-chrome;
    commandLineArgs = [
      "--enable-features=VaapiVideoDecoder"
      "--enable-gpu-rasterization"
    ];
  };
}
