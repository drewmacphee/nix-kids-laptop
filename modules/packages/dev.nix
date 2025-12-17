{ config, pkgs, ... }:

{
  # Development tools for admin users
  home.packages = with pkgs; [
    python3
    nodejs
    git
  ];
  
  # VS Code with extensions and settings
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    extensions = with pkgs.vscode-extensions; [
      ms-python.python
      ms-vscode-remote.remote-ssh
      jnoortheen.nix-ide
    ];
    userSettings = {
      "update.mode" = "none";
      "extensions.autoUpdate" = false;
    };
  };
}
