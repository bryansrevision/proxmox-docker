# 🔐 Connect to Proxmox Using Bitwarden + SSH

Complete guide for connecting to your Proxmox VE server (192.168.1.185) using Bitwarden vault credentials and SSH keys.

## ✅ What You Have

```
✓ Bitwarden CLI installed (version 2025.12.0)
✓ Bitwarden vault (locked, email: dylan.bryan.j@outlook.com)
✓ SSH key: id_ed25519_proxmox (encrypted, 464 bytes)
✓ SSH key fingerprint: SHA256:Ozj15ZSM9xFACSXzk8TaB0vJTK3HgoDwpTkzTR+TS3I
✓ Public key authorized on Proxmox (proxmox-automation user)
```

## 🚀 Quick Connection (3 Methods)

### Method 1: Direct SSH (Fastest)

```powershell
ssh -i C:\Users\Dylan\.ssh\id_ed25519_proxmox root@192.168.1.185
# Will prompt for SSH key passphrase
```

**Expected output:**
```
Enter passphrase for key 'C:\Users\Dylan\.ssh\id_ed25519_proxmox': 
root@pve:~#
```

### Method 2: Using Bitwarden + SSH Helper Script

```powershell
cd C:\Users\Dylan\proxmox-docker

# Unlock Bitwarden and connect
.\connect-proxmox.ps1 -Action connect -UnlockBitwarden
```

**What happens:**
1. Prompts for Bitwarden master password
2. Retrieves Proxmox credentials from vault
3. Displays credentials
4. Connects via SSH

### Method 3: Manual Bitwarden + SSH

```powershell
# Step 1: Unlock Bitwarden
bw unlock
# Enter your Bitwarden master password

# Step 2: Get Proxmox credentials
$env:BW_SESSION = & bw unlock --raw
bw list items --search "proxmox"

# Step 3: Connect via SSH
ssh -i C:\Users\Dylan\.ssh\id_ed25519_proxmox root@192.168.1.185
```

---

## 📋 Step-by-Step Setup

### Step 1: Unlock Bitwarden Vault

```powershell
# Unlock and store session token
$env:BW_SESSION = & bw unlock --raw
# Enter your Bitwarden master password
```

**Verify it worked:**
```powershell
bw status
# Should show "status":"unlocked"
```

### Step 2: List Bitwarden Items (Find Proxmox Credentials)

```powershell
# List all items
bw list items

# Or search for Proxmox
bw list items --search "proxmox"
```

**Example output:**
```
[
  {
    "object": "item",
    "id": "abc123...",
    "organizationId": null,
    "name": "Proxmox VE 192.168.1.185",
    "type": 1,
    "login": {
      "username": "root@pam",
      "password": "your-proxmox-password",
      "uri": "https://192.168.1.185:8006"
    }
  }
]
```

### Step 3: Get Specific Credentials

```powershell
# Get item by ID
$item = bw get item "abc123..." | ConvertFrom-Json

# Extract credentials
$username = $item.login.username
$password = $item.login.password

Write-Host "Username: $username"
Write-Host "Password: $($password.Substring(0,3))***"
```

### Step 4: Connect via SSH

```powershell
# Using SSH key (recommended)
ssh -i C:\Users\Dylan\.ssh\id_ed25519_proxmox root@192.168.1.185

# When prompted, enter SSH key passphrase
# Then you have shell access:
# root@pve:~#
```

---

## 🔐 Your SSH Key Information

### Key Details
```
Type:           ED25519 (modern, secure)
Location:       C:\Users\Dylan\.ssh\id_ed25519_proxmox
Public Key:     C:\Users\Dylan\.ssh\id_ed25519_proxmox.pub
Status:         Encrypted (requires passphrase)
Fingerprint:    SHA256:Ozj15ZSM9xFACSXzk8TaB0vJTK3HgoDwpTkzTR+TS3I
Proxmox User:   proxmox-automation
```

### Public Key
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPufGcjfLdUxy5xwomso42/kIBj2/mqHdK5gz9q9Rwnr proxmox-automation
```

### Private Key (Encrypted)
```
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAACmFlczI1Ni1jdHIAAAAGYmNyeXB0AAAAGAAAABDODe2r+j
iOs+1lenPUvfn1AAAAGAAAAAEAAAAzAAAAC3NzaC1lZDI1NTE5AAAAIPufGcjfLdUxy5xw
[... encrypted content ...]
-----END OPENSSH PRIVATE KEY-----
```

---

## 🎯 Using the Connection Helper Script

I created `connect-proxmox.ps1` for easy connection management.

### Usage Examples

**Check Bitwarden status:**
```powershell
.\connect-proxmox.ps1 -Action status
```

**List all vault items:**
```powershell
.\connect-proxmox.ps1 -Action list -UnlockBitwarden
```

**Get Proxmox credentials:**
```powershell
.\connect-proxmox.ps1 -Action get-proxmox -UnlockBitwarden
```

**Connect via SSH:**
```powershell
.\connect-proxmox.ps1 -Action connect-ssh
```

**Full connection (Bitwarden + SSH):**
```powershell
.\connect-proxmox.ps1 -Action connect -UnlockBitwarden
```

---

## 🔑 What You Can Do After Connecting

Once logged in via SSH (root@pve:~#):

### System Information
```bash
# Check Proxmox version
pveversion

# Check cluster status
pvesh get /cluster/status

# List nodes
pvesh get /nodes

# List VMs/Containers
pvesh get /nodes/pve/qemu
pvesh get /nodes/pve/lxc
```

### VM Management (if you have pxmgr installed)
```bash
# List all VMs
pxmgr vm list

# List nodes
pxmgr node list

# Get node info
pxmgr node info pve

# View storage
pxmgr node storage pve
```

### Direct Proxmox API (if using token)
```bash
# Check if you can access API
curl -k -H "Authorization: PVEAPIToken=..." https://localhost:8006/api2/json/nodes
```

---

## 🚨 Troubleshooting

### SSH Key Passphrase Issues

**Error: "Bad decrypt" or passphrase not accepted**
```powershell
# The SSH key is encrypted. You need the correct passphrase
# If you forgot it, you need to generate a new one

# Check key exists
Test-Path C:\Users\Dylan\.ssh\id_ed25519_proxmox

# Try connecting again (might have mistyped passphrase)
ssh -i C:\Users\Dylan\.ssh\id_ed25519_proxmox root@192.168.1.185
```

### Bitwarden Not Unlocking

**Error: "Bitwarden vault is locked"**
```powershell
# Method 1: Use the helper script
.\connect-proxmox.ps1 -UnlockBitwarden

# Method 2: Manual unlock
bw unlock
# Enter your Bitwarden master password
```

### SSH Connection Refused

**Error: "Connection refused" or "Permission denied"**
```powershell
# Check if Proxmox is reachable
Test-NetConnection -ComputerName 192.168.1.185 -Port 22

# Check SSH service is running on Proxmox
# (You may need to login another way or check server)

# Verify public key is authorized on Proxmox
ssh-keyscan -t ed25519 192.168.1.185
```

### Bitwarden Session Expires

**Error: "Bitwarden session expired"**
```powershell
# Re-unlock vault
$env:BW_SESSION = & bw unlock --raw

# Or run helper script again
.\connect-proxmox.ps1 -UnlockBitwarden
```

---

## 🔐 Security Best Practices

### SSH Key Security
```powershell
# ✅ DO:
- Keep private key (id_ed25519_proxmox) secure
- Use SSH key passphrase protection
- Rotate SSH keys regularly
- Store public key on servers only

# ❌ DON'T:
- Share private key
- Store passphrase in scripts (except encrypted vaults)
- Use unencrypted keys
- Commit keys to version control
```

### Bitwarden Security
```powershell
# ✅ DO:
- Use strong master password
- Keep Bitwarden CLI updated
- Lock vault when not in use
- Use BW_SESSION for automation (temporary)

# ❌ DON'T:
- Store master password in scripts
- Share vault access
- Keep vault unlocked
- Store session tokens permanently
```

### SSH Session Security
```bash
# After connecting to Proxmox:

# Lock your screen when away
Ctrl+L

# Exit/logout when done
exit

# Or if using SSH for automation:
# - Use limited permissions tokens
# - Use read-only API for monitoring
# - Rotate credentials regularly
```

---

## 📊 Connection Flow Diagram

```
Your Computer (Windows)
    ↓
Bitwarden CLI (installed)
    ↓
  Unlock vault (master password)
    ↓
  Retrieve Proxmox credentials
    ↓
SSH Client (Windows built-in)
    ↓
SSH Key (id_ed25519_proxmox)
    ↓
Proxmox Server (192.168.1.185)
    ↓
Shell Access (root@pve:~#)
```

---

## ✅ Complete Connection Checklist

- [ ] Bitwarden CLI installed: `bw --version`
- [ ] SSH key exists: `ls C:\Users\Dylan\.ssh\id_ed25519_proxmox`
- [ ] Bitwarden has Proxmox credentials stored
- [ ] Proxmox public key authorized (already done)
- [ ] Can reach Proxmox: `ping 192.168.1.185`
- [ ] SSH service running on Proxmox (port 22)
- [ ] Can test SSH: `ssh -i ~/.ssh/id_ed25519_proxmox root@192.168.1.185`

---

## 🚀 Quick Start Commands

```powershell
# 1. Unlock Bitwarden
$env:BW_SESSION = & bw unlock --raw

# 2. Get Proxmox credentials
bw list items --search "proxmox"

# 3. Connect via SSH
ssh -i C:\Users\Dylan\.ssh\id_ed25519_proxmox root@192.168.1.185

# 4. Now you're in: root@pve:~#
# 5. Check status
pveversion

# 6. Exit
exit
```

---

## 📚 Related Files

- **connect-proxmox.ps1** - PowerShell helper script
- **SSH-TOKEN-AUTHENTICATION.md** - Authentication guide
- **PROXMOX-SSH-SETUP.md** - SSH setup guide
- **.ssh/id_ed25519_proxmox** - Your SSH private key
- **.ssh/id_ed25519_proxmox.pub** - Your SSH public key

---

**You're all set to connect to Proxmox using Bitwarden + SSH!**

**Next step:** Run `ssh -i C:\Users\Dylan\.ssh\id_ed25519_proxmox root@192.168.1.185`
