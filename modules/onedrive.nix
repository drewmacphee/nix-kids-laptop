{ config, pkgs, lib, ... }:

let
  cfg = config.modules.onedrive;
in
{
  options.modules.onedrive = {
    enable = lib.mkEnableOption "OneDrive sync service";
    
    email = lib.mkOption {
      type = lib.types.str;
      description = "OneDrive email address";
    };
  };
  
  config = lib.mkIf cfg.enable {
    # OneDrive systemd service
    systemd.user.services.onedrive = {
      Unit = {
        Description = "OneDrive Sync Service";
        After = [ "network-online.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.rclone}/bin/rclone mount onedrive: ${config.home.homeDirectory}/OneDrive --vfs-cache-mode writes --config ${config.home.homeDirectory}/.config/rclone/rclone.conf";
        ExecStop = "/run/current-system/sw/bin/fusermount -u ${config.home.homeDirectory}/OneDrive";
        Restart = "on-failure";
        RestartSec = "10s";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
    
    # Create OneDrive mount point
    home.file."OneDrive/.keep".text = "";
  };
}
