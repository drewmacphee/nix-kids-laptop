# Secrets Management with sops-nix

## Overview

This configuration uses [sops-nix](https://github.com/Mic92/sops-nix) to manage secrets securely:

- **Secrets are encrypted** in the git repository using age encryption
- **Secrets are decrypted** automatically at system build/activation time
- **No plaintext secrets** are stored in git
- **Per-host encryption keys** ensure secrets can only be decrypted on authorized machines

## How It Works

1. **Age Keys**: Each host has a unique age key stored in `/var/lib/sops-nix/key.txt`
2. **Encrypted Secrets**: The `secrets/secrets.yaml` file contains all secrets, encrypted with host age keys
3. **Automatic Decryption**: sops-nix decrypts secrets during nixos-rebuild and places them in `/run/secrets/`
4. **Configuration References**: NixOS configuration references these decrypted secrets

## During Bootstrap

The bootstrap script:
1. Retrieves secrets from Azure Key Vault
2. Generates an age key pair for the host
3. Creates an encrypted `secrets/secrets.yaml` file using sops
4. Commits the encrypted secrets to git (safe to store publicly)
5. The age private key stays on the local machine only

## Stored Secrets

- **User passwords** (hashed)
- **SSH authorized keys**
- **OneDrive rclone configurations**
- **WiFi credentials**

## Adding/Updating Secrets

### Option 1: Via Azure Key Vault (Recommended)
```bash
# Update secret in Key Vault
az keyvault secret set --vault-name nix-systems-kv --name passwords-drew --value "newpassword"

# Re-run bootstrap to sync
curl -L https://raw.githubusercontent.com/drewmacphee/nix-systems/main/bootstrap.sh | sudo bash
```

### Option 2: Edit Encrypted File Directly
```bash
# Install sops
nix-shell -p sops

# Edit secrets (requires access to host's age key)
cd /etc/nixos
export SOPS_AGE_KEY_FILE=/var/lib/sops-nix/key.txt
sops secrets/secrets.yaml

# Commit changes
git add secrets/secrets.yaml
git commit -m "Update secrets"
git push
```

## Security Notes

- ✅ **Safe to commit**: `secrets/secrets.yaml` (encrypted)
- ✅ **Safe to commit**: `.sops.yaml` (contains public keys only)
- ❌ **Never commit**: `/var/lib/sops-nix/key.txt` (private age key)
- ❌ **Never commit**: `/run/secrets/*` (decrypted secrets)

## Key Backup

**IMPORTANT**: The age private key at `/var/lib/sops-nix/key.txt` is the only way to decrypt secrets for this host.

To back up the key to Azure Key Vault:
```bash
az keyvault secret set \
  --vault-name nix-systems-kv \
  --name "age-key-$(hostname)" \
  --file /var/lib/sops-nix/key.txt
```

To restore a lost key:
```bash
sudo mkdir -p /var/lib/sops-nix
az keyvault secret show \
  --vault-name nix-systems-kv \
  --name "age-key-$(hostname)" \
  --query value -o tsv | sudo tee /var/lib/sops-nix/key.txt
sudo chmod 600 /var/lib/sops-nix/key.txt
```
