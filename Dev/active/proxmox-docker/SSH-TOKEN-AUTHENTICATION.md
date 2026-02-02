# 🔐 SSH vs Token Authentication - Complete Guide

## Quick Answer

**SSH** = Direct shell access to Proxmox server (terminal login)  
**Token** = API authentication for pxmgr CLI tool (programmatic access)

**You need BOTH to fully manage Proxmox:**
- **SSH**: For direct server management
- **Token**: For using pxmgr CLI tool

---

## 🔑 SSH Login (Direct Server Access)

### What is SSH?
SSH = Secure Shell. It's like remote login to your Proxmox server terminal.

### Prerequisites
1. SSH key pair (public + private)
2. Private key authorized on Proxmox server
3. Proxmox SSH access enabled (default)

### Step 1: Generate SSH Key (One Time)

**On Windows PowerShell:**
```powershell
# Create .ssh directory
mkdir -Force $HOME\.ssh

# Generate RSA key pair
ssh-keygen -t rsa -b 4096 -f "$HOME\.ssh\id_rsa" -N ""

# Verify
ls $HOME\.ssh\
```

**Output:**
```
Mode                 LastWriteTime         Length Name
----                 -----                 ------ ----
-a---            1/11/2026  11:00 AM        3272 id_rsa        (PRIVATE - keep secret!)
-a---            1/11/2026  11:00 AM         748 id_rsa.pub    (PUBLIC - share this)
```

### Step 2: Authorize Your Key on Proxmox

**Option A: Using ssh-copy-id (Easiest)**

If you have password access to Proxmox:
```bash
ssh-copy-id -i "$HOME\.ssh\id_rsa.pub" root@192.168.1.185
# Enter password when prompted
```

**Option B: Manual Authorization**

If you already have SSH access:
```bash
# 1. SSH to Proxmox with password
ssh root@192.168.1.185

# 2. Create .ssh directory
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# 3. Add your public key
echo "your-public-key-content-here" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# 4. Exit
exit
```

**Option C: Copy and Paste Public Key**

```bash
# 1. Get your public key (entire content)
cat $HOME\.ssh\id_rsa.pub

# 2. Copy the output
# 3. SSH to Proxmox with password
ssh root@192.168.1.185

# 4. Add key manually
cat >> ~/.ssh/authorized_keys << 'EOF'
ssh-rsa AAAAB3NzaC1yc2E... (paste your public key here)
EOF

# 5. Exit
exit
```

### Step 3: Login via SSH

```bash
# Using private key (no password needed)
ssh -i "$HOME\.ssh\id_rsa" root@192.168.1.185

# Or from Docker container
docker-compose run --rm -it proxmox-platform shell
ssh root@192.168.1.185
```

**You should see:**
```
root@pve:~#
```

Congratulations! You're logged in via SSH!

---

## 🎫 Token Authentication (API Access for pxmgr)

### What is a Token?
A token = secure API credential. Like a password for the pxmgr CLI tool.

### Prerequisites
1. Proxmox server accessible via IP
2. API token created in Proxmox UI
3. Token credentials in `.env` file

### Step 1: Create API Token in Proxmox UI

1. **Open Proxmox Web Interface:**
   ```
   https://192.168.1.185:8006
   ```

2. **Login** with your username/password

3. **Navigate to API Tokens:**
   ```
   Datacenter → Permissions → API Tokens
   ```

4. **Click "Add"**

5. **Fill in the form:**
   ```
   User: root (or your username)
   Token ID: automation (or any name)
   Expire: (leave empty = never expires, or set date)
   Privileges: (leave defaults or set to PVEAdmin for full access)
   ```

6. **Click "Add"**

7. **⚠️ IMPORTANT: Copy the token value immediately!**
   ```
   Example output:
   Token ID: automation
   Secret: a2376549-e648-4f47-96cb-2b2933614a50
   ```
   This is shown **ONLY ONCE** - save it securely!

### Step 2: Add Token to .env File

**In Docker setup:**
```bash
cd C:\Users\Dylan\proxmox-docker

# Edit .env
notepad .env
```

**Add these lines:**
```env
PROXMOX_HOST=192.168.1.185
PROXMOX_PORT=8006
PROXMOX_USER=root@pam
PROXMOX_TOKEN_NAME=automation
PROXMOX_TOKEN_VALUE=a2376549-e648-4f47-96cb-2b2933614a50
PROXMOX_VERIFY_SSL=false
```

**Or in Proxmox repo:**
```bash
cd C:\Users\Dylan\proxmox-personal-data-platform

# Create .env
copy .env.example .env

# Edit with same content
notepad .env
```

### Step 3: Use Token with pxmgr

```bash
# Test connection
docker-compose run --rm proxmox-platform test

# List nodes
docker-compose run --rm proxmox-platform node list

# List VMs
docker-compose run --rm proxmox-platform vm list

# Start VM
docker-compose run --rm proxmox-platform vm start 100
```

---

## 📊 Comparison: SSH vs Token

| Feature | SSH | Token |
|---------|-----|-------|
| **Purpose** | Direct server shell access | API/CLI tool access |
| **Login Type** | Interactive terminal | Programmatic (automated) |
| **How Created** | ssh-keygen | Proxmox UI |
| **Authentication** | Private key file | Token string |
| **Used For** | Direct server management | pxmgr CLI, automation |
| **Example Command** | `ssh root@192.168.1.185` | `pxmgr node list` |

---

## 🔐 Complete Setup Workflow

### Step 1: SSH Setup (15 minutes)

```powershell
# Generate key
ssh-keygen -t rsa -b 4096 -f "$HOME\.ssh\id_rsa" -N ""

# Authorize on Proxmox
ssh-copy-id -i "$HOME\.ssh\id_rsa.pub" root@192.168.1.185
# Or manually authorize (see above)

# Test SSH login
ssh -i "$HOME\.ssh\id_rsa" root@192.168.1.185
# You should see: root@pve:~#
# Type: exit
```

### Step 2: Token Setup (5 minutes)

1. Open: `https://192.168.1.185:8006`
2. Go to: Datacenter → Permissions → API Tokens
3. Click "Add"
4. Create "automation" token
5. **Copy token value**

### Step 3: Configure .env (2 minutes)

```bash
cd C:\Users\Dylan\proxmox-docker

# Copy template
copy .env.example .env

# Edit with your values
notepad .env
```

Add:
```env
PROXMOX_HOST=192.168.1.185
PROXMOX_USER=root@pam
PROXMOX_TOKEN_NAME=automation
PROXMOX_TOKEN_VALUE=<paste-token-here>
PROXMOX_VERIFY_SSL=false
```

### Step 4: Test Both Methods (5 minutes)

**Test SSH:**
```bash
ssh -i "$HOME\.ssh\id_rsa" root@192.168.1.185
exit
```

**Test Token:**
```bash
docker-compose run --rm proxmox-platform test
```

---

## 🎯 Using SSH from Docker

### Method 1: SSH from Inside Container

```bash
cd C:\Users\Dylan\proxmox-docker

# Enter container shell
docker-compose run --rm -it proxmox-platform shell

# Inside container, SSH to Proxmox
ssh root@192.168.1.185
# or with explicit key
ssh -i ~/.ssh/id_rsa root@192.168.1.185

# Exit SSH
exit

# Exit container
exit
```

### Method 2: Mount SSH Keys to Container

```bash
# Run with SSH key mounted
docker-compose run --rm -it \
  -v "$HOME\.ssh:/home/pxmgr/.ssh:ro" \
  proxmox-platform shell

# Inside container
ssh root@192.168.1.185
```

### Method 3: Configure in .env

In `.env`, set:
```env
PROXMOX_SSH_HOST=192.168.1.185
PROXMOX_SSH_PORT=22
PROXMOX_SSH_USER=root
PROXMOX_SSH_KEY_PATH=~/.ssh/id_rsa
```

Then the docker container has SSH ready to use.

---

## 🎯 Using Token with pxmgr

### Basic Usage

```bash
# List all nodes
pxmgr node list

# List all VMs
pxmgr vm list

# Start specific VM
pxmgr vm start 100

# Stop VM (dry-run first)
pxmgr vm stop 100 --dry-run
pxmgr vm stop 100

# Get detailed node info
pxmgr node info pve-node-01

# Show cluster status
pxmgr status
```

### With Docker

```bash
cd C:\Users\Dylan\proxmox-docker

# List nodes
docker-compose run --rm proxmox-platform node list

# List VMs
docker-compose run --rm proxmox-platform vm list

# Interactive shell
docker-compose run --rm -it proxmox-platform shell

# Run command with env override
docker-compose run \
  -e PXMGR_OUTPUT_FORMAT=json \
  proxmox-platform vm list
```

---

## 🚨 Troubleshooting

### SSH Issues

**Error: "Permission denied (publickey)"**
- Cause: Key not authorized on Proxmox
- Fix: Run `ssh-copy-id` to authorize
- Or manually add public key to `~/.ssh/authorized_keys`

**Error: "Could not resolve hostname"**
- Cause: Wrong IP address
- Fix: Verify `PROXMOX_HOST` is correct
- Test: `ping 192.168.1.185`

**Error: "Connection refused"**
- Cause: SSH not running or port 22 blocked
- Fix: Check firewall allows SSH port 22
- Verify: `telnet 192.168.1.185 22`

### Token Issues

**Error: "401 Unauthorized"**
- Cause: Invalid token value
- Fix: Verify token in `.env` is correct
- Re-create token if needed

**Error: "Connection refused"**
- Cause: Proxmox API not accessible
- Fix: Verify `PROXMOX_HOST` is reachable
- Check: Port 8006 is open

**Error: "CERTIFICATE_VERIFY_FAILED"**
- Cause: Self-signed SSL certificate
- Fix: Set `PROXMOX_VERIFY_SSL=false` in `.env`

---

## 🔒 Security Best Practices

### SSH Key Security
```bash
# Set correct permissions (Linux/Mac)
chmod 600 ~/.ssh/id_rsa

# Never share private key
# Only share public key (.pub)

# Rotate keys regularly (yearly recommended)
# Create new key pair and re-authorize
```

### Token Security
```bash
# Create separate tokens for different purposes
# Example tokens:
#   - automation (for pxmgr)
#   - backup (for backup scripts)
#   - monitoring (for monitoring tools)

# Each token should have minimum required permissions
# Never commit .env to git
# Store .env with chmod 600 permissions

# Rotate tokens every 90 days
# Delete old tokens after rotation
```

### .env File Protection
```bash
# Secure .env file permissions
chmod 600 .env

# Never commit to git
# Add to .gitignore
echo ".env" >> .gitignore

# Store in secure location
# Consider using Bitwarden for credentials
```

---

## 📚 Next Steps

1. **Generate SSH key**: `ssh-keygen -t rsa -b 4096`
2. **Authorize on Proxmox**: `ssh-copy-id`
3. **Test SSH**: `ssh root@192.168.1.185`
4. **Create API token** in Proxmox UI
5. **Add token to .env**
6. **Test token**: `docker-compose run --rm proxmox-platform test`
7. **Use pxmgr**: `pxmgr node list`

---

## 📖 Command Reference

### SSH Commands
```bash
# Login via SSH
ssh -i ~/.ssh/id_rsa root@192.168.1.185

# From Docker
docker-compose run --rm -it proxmox-platform shell
ssh root@192.168.1.185

# Copy public key to server
ssh-copy-id -i ~/.ssh/id_rsa.pub root@192.168.1.185

# Execute remote command
ssh -i ~/.ssh/id_rsa root@192.168.1.185 "pveversion"

# SCP file to server
scp -i ~/.ssh/id_rsa myfile.txt root@192.168.1.185:/tmp/
```

### pxmgr Commands (Token-based)
```bash
# Test connection
pxmgr test

# List resources
pxmgr node list
pxmgr vm list
pxmgr api status

# Manage VMs
pxmgr vm start 100
pxmgr vm stop 100
pxmgr vm clone 100 200 --name new-vm

# Get info
pxmgr node info pve
pxmgr node storage pve

# Run wizard
pxmgr setup wizard
pxmgr assistant
```

---

## ✅ Verification Checklist

- [ ] SSH key generated: `ls ~/.ssh/id_rsa`
- [ ] Key authorized: `ssh root@192.168.1.185` works
- [ ] API token created in Proxmox UI
- [ ] .env file created with token
- [ ] pxmgr test passes: `pxmgr test`
- [ ] Can list nodes: `pxmgr node list`
- [ ] Can list VMs: `pxmgr vm list`

---

**Now you can manage Proxmox via both SSH (direct access) and Token (CLI tool)!**
