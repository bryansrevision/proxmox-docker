# 🔐 Proxmox SSH Connection Setup Guide

Your Proxmox Personal Data Platform repository is ready to use. Here's how to connect to your Proxmox VE server.

## 🎯 Current Status

✅ **Cloned Repository**: `C:\Users\Dylan\proxmox-personal-data-platform\`  
✅ **Docker Setup Ready**: `C:\Users\Dylan\proxmox-docker\`  
⚠️ **SSH Key Status**: Not found at `C:\Users\Dylan\.ssh\id_rsa`  
❌ **Proxmox .env**: No credentials configured yet

## 📋 What You Need

Before connecting, prepare these 4 items:

| Item | Example | Note |
|------|---------|------|
| **Proxmox IP** | `192.168.1.185` | Your server IP |
| **SSH User** | `root` | Default user |
| **SSH Key** | `id_rsa` | Private key file |
| **SSH Port** | `22` | Usually 22 |

## 🚀 Option 1: Quick SSH via Docker (Easiest)

Since you don't have an SSH key yet, use the Docker container which can handle SSH:

```bash
cd C:\Users\Dylan\proxmox-docker

# Edit .env with your Proxmox details
copy .env.example .env
notepad .env

# Configure SSH settings:
# PROXMOX_SSH_HOST=192.168.1.185
# PROXMOX_SSH_USER=root
# PROXMOX_SSH_PORT=22
```

Then connect via Docker:
```bash
docker-compose run --rm -it proxmox-platform shell
```

This gives you a bash shell inside the container where you can:
```bash
ssh root@192.168.1.185
```

## 🔑 Option 2: Create SSH Key & Connect Directly

### Step 1: Generate SSH Key Pair

**Using PowerShell (Recommended):**
```powershell
# Create .ssh directory if it doesn't exist
mkdir -Force $HOME\.ssh

# Generate RSA key (no passphrase)
ssh-keygen -t rsa -b 4096 -f "$HOME\.ssh\id_rsa" -N ""

# Verify it was created
ls $HOME\.ssh\
```

**Output should show:**
```
id_rsa        (private key - 3.2 KB)
id_rsa.pub    (public key - 0.7 KB)
```

### Step 2: Copy Public Key to Proxmox

You need to authorize your public key on the Proxmox server. There are two ways:

**Method A: If you already have password access:**
```bash
ssh-copy-id -i $HOME\.ssh\id_rsa.pub root@192.168.1.185
# Enter password when prompted
```

**Method B: Manual (if password access unavailable):**
1. Get your public key: `cat $HOME\.ssh\id_rsa.pub`
2. SSH to Proxmox (use password)
3. Add key: `echo "your-public-key-here" >> ~/.ssh/authorized_keys`

### Step 3: Test SSH Connection

```bash
# Test connection
ssh -i $HOME\.ssh\id_rsa root@192.168.1.185

# Or with Docker (easier):
cd C:\Users\Dylan\proxmox-docker
docker-compose run --rm -it proxmox-platform shell
ssh root@192.168.1.185
```

## 📂 Repository Structure for SSH Setup

```
C:\Users\Dylan\proxmox-personal-data-platform\
├── scripts/
│   ├── setup/
│   │   ├── auto-setup.sh         ← Automated setup
│   │   ├── config-collector.py   ← Gathers Proxmox config
│   │   └── setup-wizard.py       ← Interactive setup
│   └── bitwarden/
│       └── bw-manager.sh         ← Credential management
├── src/
│   └── pxmgr/                    ← Main CLI tool
├── .env.example                  ← Configuration template
└── README.md                      ← Documentation
```

## 📝 Setting Up Proxmox Connection

### Step 1: Create .env File

In the Proxmox repo, create `.env`:

```bash
cd C:\Users\Dylan\proxmox-personal-data-platform
copy .env.example .env
notepad .env
```

### Step 2: Add Your Proxmox Credentials

Edit `.env` with:

```env
# Required for API/SSH
PROXMOX_HOST=192.168.1.185
PROXMOX_PORT=8006
PROXMOX_USER=root@pam

# Choose ONE authentication method:

# Option A: API Token (Recommended)
PROXMOX_TOKEN_NAME=automation
PROXMOX_TOKEN_VALUE=your-token-uuid-here

# Option B: Password (Less Secure)
# PROXMOX_PASSWORD=your-password

# SSL Options
PROXMOX_VERIFY_SSL=false          # For self-signed certs

# SSH Configuration
PROXMOX_SSH_HOST=192.168.1.185
PROXMOX_SSH_PORT=22
PROXMOX_SSH_USER=root
PROXMOX_SSH_KEY_PATH=~/.ssh/id_rsa
```

### Step 3: Get Your API Token

To create an API token for secure access:

1. Open Proxmox web UI: `https://192.168.1.185:8006`
2. Go to: **Datacenter** → **Permissions** → **API Tokens**
3. Click "Add"
4. Fill in:
   - **User**: root (or your username)
   - **Token ID**: automation
   - **Expire**: (leave empty or set future date)
5. **COPY the token value** (shown only once!)
6. Paste into `.env` file

### Step 4: Test Connection

```bash
# Test API connection
python scripts/setup/config-collector.py

# Or using Docker
cd C:\Users\Dylan\proxmox-docker
docker-compose run --rm proxmox-platform test
```

## 🔧 Using Proxmox CLI (pxmgr)

Once configured, use the CLI:

```bash
cd C:\Users\Dylan\proxmox-personal-data-platform

# List nodes
python -m pxmgr node list

# List VMs
python -m pxmgr vm list

# Start VM
python -m pxmgr vm start 100

# Interactive assistant
python -m pxmgr assistant

# Run setup wizard
python -m pxmgr setup wizard
```

Or via Docker:

```bash
cd C:\Users\Dylan\proxmox-docker

docker-compose run --rm proxmox-platform node list
docker-compose run --rm proxmox-platform vm list
docker-compose run --rm -it proxmox-platform shell
```

## 🆘 Connection Troubleshooting

### SSH: "Permission denied"
- **Cause**: SSH key not authorized on Proxmox
- **Fix**: Run `ssh-copy-id` to add your public key

### SSH: "No such file or directory"
- **Cause**: SSH key doesn't exist
- **Fix**: Generate with `ssh-keygen` (see above)

### API: "Connection refused"
- **Cause**: Proxmox not accessible
- **Fix**: Check IP is correct, firewall allows port 8006

### API: "401 Unauthorized"
- **Cause**: Invalid token/password
- **Fix**: Verify credentials in .env

### SSL: "CERTIFICATE_VERIFY_FAILED"
- **Cause**: Self-signed certificate
- **Fix**: Set `PROXMOX_VERIFY_SSL=false`

## 🚀 Complete Quick Start

```powershell
# 1. Generate SSH key
ssh-keygen -t rsa -b 4096 -f "$HOME\.ssh\id_rsa" -N ""

# 2. Create .env in repo
cd C:\Users\Dylan\proxmox-personal-data-platform
copy .env.example .env
notepad .env
# Edit with your Proxmox IP, user, token

# 3. Test connection using Docker
cd C:\Users\Dylan\proxmox-docker
docker-compose run --rm proxmox-platform test

# 4. Direct SSH if key is authorized
ssh -i $HOME\.ssh\id_rsa root@192.168.1.185

# 5. Or via Docker shell
docker-compose run --rm -it proxmox-platform shell
# Then: ssh root@192.168.1.185
```

## 📚 Related Documentation

- **Docker Setup**: `C:\Users\Dylan\proxmox-docker\INDEX.md`
- **Proxmox Repo**: `C:\Users\Dylan\proxmox-personal-data-platform\README.md`
- **Security Guide**: `C:\Users\Dylan\proxmox-personal-data-platform\SECURITY.md`
- **Usage Guide**: `C:\Users\Dylan\proxmox-personal-data-platform\USAGE.md`

## ✅ Checklist

- [ ] SSH key generated: `ssh-keygen -t rsa -b 4096`
- [ ] Public key authorized on Proxmox: `ssh-copy-id`
- [ ] .env file created with Proxmox IP
- [ ] API token obtained from Proxmox UI
- [ ] Token added to .env file
- [ ] Connection tested: `python scripts/setup/config-collector.py`
- [ ] SSH test: `ssh -i ~/.ssh/id_rsa root@192.168.1.185`

## 🎯 Next Steps

1. **Generate SSH key**: `ssh-keygen -t rsa -b 4096 -f $HOME\.ssh\id_rsa -N ""`
2. **Create .env**: Copy `.env.example` to `.env` in repo
3. **Add credentials**: Edit .env with Proxmox details
4. **Test connection**: Use Docker or direct SSH
5. **Explore**: Run `pxmgr --help` to see available commands

---

**Ready to connect?** Start with Step 1 above or use Docker for easier setup!
