{ config, pkgs, ... }:

{
  # Common configuration shared by all users
  
  # Let Home Manager manage itself
  programs.home-manager.enable = true;
  
  # Home Manager state version
  home.stateVersion = "24.05";
  
  # Git configuration (username/email set per-user)
  programs.git = {
    enable = true;
  };
  
  # Bash configuration with common aliases
  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -la";
      update = "sudo nixos-rebuild switch --flake /etc/nixos#nix-kids-laptop";
    };
  };
}
