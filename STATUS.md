# Project Status - December 15, 2024

## ✅ COMPLETED

### GitHub Repository
- **URL**: https://github.com/drewmacphee/nix-kids-laptop
- **Status**: Public, all files pushed
- **Bootstrap Script**: https://raw.githubusercontent.com/drewmacphee/nix-kids-laptop/main/bootstrap.sh

### Azure Key Vault
- **Vault**: https://nix-kids-laptop.vault.azure.net/
- **Uploaded Secrets (3/6)**:
  - ✅ `drew-ssh-authorized-keys`
  - ✅ `emily-ssh-authorized-keys`
  - ✅ `bella-ssh-authorized-keys`

### NixOS Configuration
- ✅ Complete system configuration with GNOME
- ✅ 3 user accounts (Drew, Emily, Bella)
- ✅ Gaming setup (Steam, Minecraft/PrismLauncher, Proton)
- ✅ Applications (Chrome, VS Code, LibreOffice, GIMP, educational apps)
- ✅ Home Manager configs for each user
- ✅ SSH remote access configured
- ✅ OneDrive systemd services (pending rclone configs)

### Documentation
- ✅ README.md - Main documentation
- ✅ QUICK-START.md - Fast setup guide
- ✅ SETUP-SIMPLIFIED.md - Detailed walkthrough
- ✅ ONEDRIVE-SETUP.md - OneDrive configuration guide
- ✅ KEYVAULT-SECRETS.md - Architecture explanation
- ✅ KEYVAULT-SETUP-GUIDE.md - Key Vault setup steps
- ✅ TODO.md - Remaining tasks

### Tools Created
- ✅ `bootstrap.sh` - One-command NixOS installer
- ✅ `setup-keyvault.ps1` - Interactive Key Vault setup (Windows)
- ✅ `setup-keyvault.sh` - Interactive Key Vault setup (Linux)

## ⚠️ TODO - Before First Bootstrap

### 1. Configure OneDrive (CRITICAL)
The system will bootstrap and work, but OneDrive won't mount until these are uploaded:

```powershell
# Install rclone
winget install Rclone.Rclone

# For Drew
rclone config  # Login with drewjamesross@outlook.com
az keyvault secret set --vault-name nix-kids-laptop --name drew-rclone-config --file "$env:APPDATA\rclone\rclone.conf"

# For Emily
Remove-Item "$env:APPDATA\rclone\rclone.conf"
rclone config  # Login with emilykamacphee@outlook.com
az keyvault secret set --vault-name nix-kids-laptop --name emily-rclone-config --file "$env:APPDATA\rclone\rclone.conf"

# For Bella
Remove-Item "$env:APPDATA\rclone\rclone.conf"
rclone config  # Login with isabellaleblanc@outlook.com
az keyvault secret set --vault-name nix-kids-laptop --name bella-rclone-config --file "$env:APPDATA\rclone\rclone.conf"
```

### 2. Verify All Secrets
```bash
az keyvault secret list --vault-name nix-kids-laptop --query "[].name" -o table
```

Should show 6 secrets total.

### 3. Test Bootstrap (Recommended)
Test on a VM or spare machine before production use:
```bash
curl -L https://raw.githubusercontent.com/drewmacphee/nix-kids-laptop/main/bootstrap.sh | sudo bash
```

## 🚀 PRODUCTION BOOTSTRAP READY

Once OneDrive configs are uploaded, you can bootstrap the kids' laptop with:

```bash
curl -L https://raw.githubusercontent.com/drewmacphee/nix-kids-laptop/main/bootstrap.sh | sudo bash
```

**What happens:**
1. Prompts for Azure login (device code)
2. Fetches all 6 secrets from Key Vault
3. Clones this repository to /etc/nixos
4. Runs nixos-rebuild with your configuration
5. Installs all packages (~10-20 minutes)
6. System ready - reboot and login!

## 📊 What Works Without OneDrive

If you bootstrap before uploading OneDrive configs:
- ✅ All 3 user accounts created
- ✅ SSH access works (keys uploaded)
- ✅ Steam, games, apps installed
- ✅ GNOME desktop fully configured
- ✅ Remote VS Code access works
- ❌ OneDrive won't mount (systemd service fails gracefully)

You can add OneDrive configs later and rebuild:
```bash
ssh drew@kids-laptop
sudo nixos-rebuild switch --flake /etc/nixos#kids-laptop
```

## 📁 Local Files

**Project Location**: `C:\git\nix-kids-laptop`

**SSH Key**: `C:\Users\drewj\.ssh\id_ed25519` (private)  
**SSH Public Key**: `C:\Users\drewj\.ssh\id_ed25519.pub` (already in Key Vault)

## 🎯 Next Immediate Action

**Configure rclone for all 3 OneDrive accounts** (see TODO.md for detailed steps)

Then you're ready to bootstrap the laptop! 🚀
