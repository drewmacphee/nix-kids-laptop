{ config, pkgs, ... }:

{
  # Development tools for admin users
  home.packages = with pkgs; [
    vscode
    python3
    nodejs
    git
  ];
}
