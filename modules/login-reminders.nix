{ config, pkgs, lib, ... }:

let
  cfg = config.modules.loginReminders;
in
{
  options.modules.loginReminders = {
    enable = lib.mkEnableOption "Login reminder desktop files";
    
    accounts = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Account reminders to create";
    };
  };
  
  config = lib.mkIf cfg.enable {
    # Create notification script that shows reminders on first login
    home.file.".local/bin/show-login-reminders" = {
      executable = true;
      text = ''
        #!/bin/sh
        # Only show once per session
        if [ -f "$HOME/.cache/login-reminders-shown" ]; then
          exit 0
        fi
        mkdir -p "$HOME/.cache"
        touch "$HOME/.cache/login-reminders-shown"
        
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: account: ''
          ${pkgs.libnotify}/bin/notify-send -i ${account.icon} "${account.hint}" "${account.message}"
        '') cfg.accounts)}
      '';
    };
    
    # Run on session start (autostart for KDE Plasma)
    home.file.".config/autostart/login-reminders.desktop" = {
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Login Reminders
        Exec=$HOME/.local/bin/show-login-reminders
        Hidden=false
        NoDisplay=false
        X-KDE-autostart-after=panel
      '';
    };
  };
}
