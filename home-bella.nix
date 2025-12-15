{ config, pkgs, ... }:

{
  home.username = "bella";
  home.homeDirectory = "/home/bella";
  home.stateVersion = "24.05";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Bella";
    userEmail = "bella@example.com";
  };

  # Bash configuration
  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -la";
      update = "sudo nixos-rebuild switch --flake /etc/nixos#nix-kids-laptop";
    };
  };

  # User packages
  home.packages = with pkgs; [
    firefox
    vlc
    libreoffice
    gimp
    inkscape
    
    # Educational software
    gcompris
    tuxpaint
    stellarium
    
    # Development tools
    python3
    nodejs
  ];

  # OneDrive systemd service
  systemd.user.services.onedrive = {
    Unit = {
      Description = "OneDrive Sync Service";
      After = [ "network-online.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.rclone}/bin/rclone mount onedrive: /home/bella/OneDrive --vfs-cache-mode writes --config /home/bella/.config/rclone/rclone.conf";
      ExecStop = "/run/current-system/sw/bin/fusermount -u /home/bella/OneDrive";
      Restart = "on-failure";
      RestartSec = "10s";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # Create OneDrive mount point
  home.file."OneDrive/.keep".text = "";

  # VS Code settings
  programs.vscode = {
    enable = true;
  };

  # PrismLauncher configuration - point to OneDrive
  home.file.".local/share/PrismLauncher/prismlauncher.cfg".text = ''
    [General]
    InstanceDir=${config.home.homeDirectory}/OneDrive/Minecraft/instances
    IconsDir=${config.home.homeDirectory}/OneDrive/Minecraft/icons
    CentralModsDir=${config.home.homeDirectory}/OneDrive/Minecraft/mods
    
    [Java]
    MaxMemAlloc=4096
    MinMemAlloc=2048
    PermGen=128
  '';

  # Create Minecraft directory structure in OneDrive
  home.activation.setupMinecraft = config.lib.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ${config.home.homeDirectory}/OneDrive/Minecraft/{instances,mods,icons,resourcepacks,screenshots}
    
    # Create helpful README
    $DRY_RUN_CMD cat > ${config.home.homeDirectory}/OneDrive/Minecraft/README.txt << 'EOF'
Minecraft Data for Bella
========================

This folder contains your Minecraft game data and syncs to OneDrive.

Your Microsoft account: isabellaleblanc@outlook.com

On first launch of PrismLauncher:
1. Click "Profiles" in the top menu
2. Click "Manage Accounts"
3. Click "Add Microsoft"
4. Login with your Microsoft account
5. Create your first instance!

All your worlds, screenshots, and settings will be saved here
and automatically backed up to OneDrive.

Happy mining!
EOF
  '';
}
