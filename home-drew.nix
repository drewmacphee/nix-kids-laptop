{ config, pkgs, ... }:

{
  imports = [
    ./modules/common.nix
    ./modules/onedrive.nix
    ./modules/minecraft.nix
    ./modules/packages/base.nix
    ./modules/packages/dev.nix
  ];

  # User identity
  home.username = "drew";
  home.homeDirectory = "/home/drew";

  # Git user configuration
  programs.git = {
    userName = "Drew";
    userEmail = "drew@example.com";
  };

  # OneDrive configuration
  modules.onedrive = {
    enable = true;
    email = "drewjamesross@outlook.com";
  };

  # Minecraft configuration
  modules.minecraft = {
    enable = true;
    email = "drewjamesross@outlook.com";
  };
}
