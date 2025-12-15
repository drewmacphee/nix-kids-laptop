# WiFi Automatic Connection

## 🌐 Overview

Your NixOS system is configured to **automatically connect to WiFi** on first boot using credentials stored securely in Azure Key Vault.

---

## ⚙️ Configuration

### Secrets in Key Vault

**WiFi credentials (2 secrets)**:
- `wifi-ssid` - Network name (currently: "1054")
- `wifi-password` - Network password (encrypted)

**Total secrets**: 11 in Key Vault

### NixOS Configuration

```nix
networking.networkmanager.ensureProfiles = {
  environmentFiles = [ "/etc/nixos/secrets/wifi-env" ];
  profiles = {
    home = {
      connection = {
        id = "Home WiFi";
        type = "wifi";
        autoconnect = true;
      };
      wifi = {
        ssid = "$WIFI_SSID";
        mode = "infrastructure";
      };
      wifi-security = {
        key-mgmt = "wpa-psk";
        psk = "$WIFI_PASSWORD";
      };
    };
  };
};
```

---

## 🚀 How It Works

### During Bootstrap

1. **Fetch credentials** from Key Vault:
   ```bash
   az keyvault secret show --vault-name nix-kids-laptop --name wifi-ssid
   az keyvault secret show --vault-name nix-kids-laptop --name wifi-password
   ```

2. **Create environment file**:
   ```bash
   echo "WIFI_SSID=1054" > /etc/nixos/secrets/wifi-env
   echo "WIFI_PASSWORD=***" >> /etc/nixos/secrets/wifi-env
   chmod 600 /etc/nixos/secrets/wifi-env
   ```

3. **NixOS rebuilds** and creates NetworkManager profile

4. **First boot**: System automatically connects to WiFi

---

## 🔐 Security

### Protection Layers

1. **Azure Key Vault**:
   - Encrypted at rest
   - Access controlled by Azure AD
   - Audit logs of all access

2. **Local File** (`/etc/nixos/secrets/wifi-env`):
   - Mode 600 (root read/write only)
   - Not in git repository
   - Fetched fresh on each bootstrap

3. **NetworkManager Profile**:
   - Stored in `/etc/NetworkManager/system-connections/`
   - Mode 600 (root only)
   - Password encrypted by NetworkManager

### What's Not Protected

⚠️ **WiFi password is in Azure Key Vault**
- Anyone with Azure access can view it
- This is a tradeoff for automation
- Alternative: Manual WiFi setup (see below)

---

## 🔄 Changing WiFi Credentials

### Update Password in Key Vault

```powershell
# From Windows with Azure CLI
az keyvault secret set `
  --vault-name nix-kids-laptop `
  --name wifi-password `
  --value "NewPassword123"
```

```bash
# From Linux/Mac
az keyvault secret set \
  --vault-name nix-kids-laptop \
  --name wifi-password \
  --value "NewPassword123"
```

### Apply to Running System

**Option 1: Rebuild (Immediate)**
```bash
ssh drew@nix-kids-laptop
cd /etc/nixos

# Fetch new password
az keyvault secret show --vault-name nix-kids-laptop --name wifi-ssid --query value -o tsv > /tmp/wifi-ssid
az keyvault secret show --vault-name nix-kids-laptop --name wifi-password --query value -o tsv > /tmp/wifi-password

# Update environment file
sudo bash -c 'echo "WIFI_SSID=$(cat /tmp/wifi-ssid)" > /etc/nixos/secrets/wifi-env'
sudo bash -c 'echo "WIFI_PASSWORD=$(cat /tmp/wifi-password)" >> /etc/nixos/secrets/wifi-env'
sudo chmod 600 /etc/nixos/secrets/wifi-env

# Rebuild
sudo nixos-rebuild switch --flake .#nix-kids-laptop

# Clean up
rm /tmp/wifi-ssid /tmp/wifi-password
```

**Option 2: Wait for Auto-Update**
- Automatic updates run at 3am daily
- Will fetch new password from Key Vault
- Takes effect after next reboot

**Option 3: Manual in GNOME**
- Click WiFi icon in top bar
- Select network
- Enter new password
- NetworkManager saves it locally

---

## 📱 Adding Additional Networks

### Add to Key Vault

**For multiple networks**, use naming convention:
```bash
# Home network
az keyvault secret set --vault-name nix-kids-laptop --name wifi-home-ssid --value "1054"
az keyvault secret set --vault-name nix-kids-laptop --name wifi-home-password --value "password1"

# School network
az keyvault secret set --vault-name nix-kids-laptop --name wifi-school-ssid --value "SchoolNet"
az keyvault secret set --vault-name nix-kids-laptop --name wifi-school-password --value "password2"
```

### Update Configuration

Edit `configuration.nix`:
```nix
networking.networkmanager.ensureProfiles = {
  environmentFiles = [ "/etc/nixos/secrets/wifi-env" ];
  profiles = {
    home = {
      connection = { id = "Home WiFi"; type = "wifi"; autoconnect = true; };
      wifi = { ssid = "$WIFI_HOME_SSID"; mode = "infrastructure"; };
      wifi-security = { key-mgmt = "wpa-psk"; psk = "$WIFI_HOME_PASSWORD"; };
    };
    school = {
      connection = { id = "School WiFi"; type = "wifi"; autoconnect = true; };
      wifi = { ssid = "$WIFI_SCHOOL_SSID"; mode = "infrastructure"; };
      wifi-security = { key-mgmt = "wpa-psk"; psk = "$WIFI_SCHOOL_PASSWORD"; };
    };
  };
};
```

Update `bootstrap.sh` to fetch both networks.

---

## 🛠️ Troubleshooting

### WiFi Not Connecting After Bootstrap

**Check if profile exists**:
```bash
nmcli connection show
# Should show "Home WiFi" profile
```

**Check environment file**:
```bash
sudo cat /etc/nixos/secrets/wifi-env
# Should show WIFI_SSID and WIFI_PASSWORD
```

**Check NetworkManager profile**:
```bash
sudo cat /etc/NetworkManager/system-connections/Home\ WiFi.nmconnection
# Should show SSID and encrypted password
```

**Manual connection**:
```bash
# Connect manually
nmcli device wifi connect "1054" password "YourPassword"

# Or use GNOME Settings → WiFi
```

### Wrong Password Stored

```bash
# Update in Key Vault
az keyvault secret set --vault-name nix-kids-laptop --name wifi-password --value "CorrectPassword"

# Rebuild system
sudo nixos-rebuild switch --flake /etc/nixos#nix-kids-laptop
```

### WiFi Works But OneDrive Doesn't

**Check OneDrive status**:
```bash
systemctl --user status onedrive
# Should be "active (running)"
```

**Check rclone mount**:
```bash
df -h | grep OneDrive
# Should show OneDrive mount
```

**Restart OneDrive**:
```bash
systemctl --user restart onedrive
```

---

## 🔄 Alternative: Manual WiFi Setup

### Disable Automatic WiFi

Remove from `configuration.nix`:
```nix
# Comment out or remove:
# networking.networkmanager.ensureProfiles = { ... };
```

### Connect Manually

**First boot**:
1. Click WiFi icon in GNOME top bar
2. Select "1054"
3. Enter password
4. NetworkManager saves it permanently

**Pros**:
- ✅ No password in Key Vault
- ✅ More secure
- ✅ Normal GNOME experience

**Cons**:
- ❌ Requires manual setup after bootstrap
- ❌ Need to repeat on fresh install

---

## 📊 Security Comparison

| Method | Password Location | Automation | Security |
|--------|------------------|------------|----------|
| **Key Vault (Current)** | Azure (encrypted) | Full | Medium |
| **Manual GNOME** | Local only | None | High |
| **Hybrid** | Both (backup) | Partial | Medium-High |

---

## 💡 Best Practices

### ✅ Do:
- Rotate WiFi password periodically
- Update Key Vault when password changes
- Use strong WiFi password (WPA2/WPA3)
- Limit Azure Key Vault access to family

### ❌ Don't:
- Share Azure credentials publicly
- Commit WiFi password to git
- Use weak WiFi passwords
- Leave WiFi open/unsecured

---

## 🎯 Summary

Your system is configured for **fully automatic WiFi connection**:

1. ✅ WiFi credentials stored in Azure Key Vault
2. ✅ Bootstrap fetches and configures automatically
3. ✅ System connects on first boot
4. ✅ OneDrive syncs immediately
5. ✅ No manual WiFi setup needed

**SSID**: 1054  
**Status**: Configured and ready

**Bootstrap will handle everything automatically!** 🎉
