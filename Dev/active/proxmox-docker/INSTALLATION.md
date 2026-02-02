# Installation Guide - Proxmox Docker Platform

This guide covers installing and running the Proxmox Personal Data Platform in Docker on Windows, macOS, or Linux.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation Steps](#installation-steps)
3. [Platform-Specific Instructions](#platform-specific-instructions)
4. [Configuration](#configuration)
5. [First Run](#first-run)
6. [Verification](#verification)

## ✅ Prerequisites

### Required

- **Docker Desktop** (Windows/Mac) or **Docker Engine** (Linux)
- **Docker Compose** (usually included with Docker Desktop)
- **Git** (optional, for cloning repository)
- **Text editor** (nano, vim, VSCode, etc.)
- **Proxmox VE Server** (version 6.x or 7.x+)
- **Proxmox API Token or Password** for authentication

### System Requirements

- **CPU**: 2+ cores
- **RAM**: 2GB minimum (4GB recommended)
- **Disk**: 1GB for Docker image + 1GB for config/logs
- **Network**: Access to Proxmox server (same LAN or VPN)

### Check Versions

```bash
docker --version
docker-compose --version
docker run hello-world
```

## 📦 Installation Steps

### Step 1: Get the Docker Setup

**Option A: Clone the Repository**
```bash
git clone https://github.com/bryansrevision/proxmox-personal-data-platform.git
cd proxmox-personal-data-platform/docker
```

**Option B: Manual Download**
```bash
# Download Docker files from repository
cd /path/to/your/proxmox-docker
# Copy Dockerfile, docker-compose.yml, etc.
```

### Step 2: Configure Your Proxmox Connection

```bash
# Copy the example configuration
cp .env.example .env

# Edit with your Proxmox details
# Windows: notepad .env
# macOS/Linux: nano .env (or vim .env)
```

**Minimal Configuration:**
```env
PROXMOX_HOST=192.168.1.185           # Your Proxmox IP
PROXMOX_USER=root@pam                # Your Proxmox user
PROXMOX_TOKEN_NAME=automation        # API token name
PROXMOX_TOKEN_VALUE=uuid-here        # API token value
PROXMOX_VERIFY_SSL=false             # For self-signed certs
```

### Step 3: Build the Docker Image

```bash
docker-compose build
```

**This will:**
- Download Python 3.11 base image
- Install dependencies
- Build the Proxmox platform
- Take 2-5 minutes on first run

### Step 4: Test the Connection

```bash
docker-compose run --rm proxmox-platform test
```

**Expected output:**
```
[INFO] Starting Proxmox Personal Data Platform
[SUCCESS] Configuration loaded
[INFO] Testing connection to 192.168.1.185:8006
✓ Connection successful
✓ Authentication valid
✓ API accessible
```

If test fails, see [Troubleshooting](#troubleshooting).

## 🖥️ Platform-Specific Instructions

### Windows

#### Install Docker Desktop

1. Download [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop)
2. Run installer and follow prompts
3. Restart your computer
4. Verify installation:
   ```
   docker --version
   docker run hello-world
   ```

#### Setup Project

```bash
# Open PowerShell or Command Prompt
cd C:\Users\YourUsername\proxmox-docker

# Run setup script
setup.bat

# Or manually:
copy .env.example .env
notepad .env
docker-compose build
docker-compose run --rm proxmox-platform test
```

#### WSL2 (Optional but Recommended)

For better performance on Windows, enable WSL2:

1. Install WSL2: https://docs.microsoft.com/windows/wsl/install
2. Set Docker to use WSL2 backend (Docker Desktop preferences)
3. Use WSL2 terminal for commands

### macOS

#### Install Docker Desktop

1. Download [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop)
2. Open installer and drag Docker to Applications
3. Open Docker application (will ask for password)
4. Verify installation:
   ```bash
   docker --version
   docker run hello-world
   ```

#### Setup Project

```bash
# Open Terminal
cd ~/proxmox-docker

# Run setup script
bash setup.sh

# Or manually:
cp .env.example .env
nano .env
docker-compose build
docker-compose run --rm proxmox-platform test
```

**Note:** Docker Desktop for Mac supports both Intel and Apple Silicon (M1/M2/M3).

### Linux

#### Install Docker Engine

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install -y docker.io docker-compose
sudo usermod -aG docker $USER
newgrp docker
```

**Fedora/RHEL:**
```bash
sudo dnf install -y docker docker-compose
sudo usermod -aG docker $USER
newgrp docker
```

**Or follow:** https://docs.docker.com/engine/install/

#### Setup Project

```bash
# Navigate to project
cd ~/proxmox-docker

# Run setup script
bash setup.sh

# Or manually:
cp .env.example .env
nano .env
docker-compose build
docker-compose run --rm proxmox-platform test
```

**Without sudo:**
```bash
# Add your user to docker group (one time)
sudo usermod -aG docker $USER
# Log out and back in, or run:
newgrp docker
```

## ⚙️ Configuration

### Getting Your Proxmox Credentials

#### API Token (Recommended)

1. Open Proxmox web UI: `https://192.168.1.185:8006`
2. Navigate to: **Datacenter** → **Permissions** → **API Tokens**
3. Click "Add"
4. Fill in:
   - **User**: `root` (or appropriate user)
   - **Tokenid**: `automation` (or your choice)
   - **Expire**: Leave empty (or set future date)
5. Click "Add"
6. **IMPORTANT**: Copy the token value immediately (shown once)
7. Optionally give Full Permissions (for testing)

Update `.env`:
```env
PROXMOX_HOST=192.168.1.185
PROXMOX_USER=root@pam
PROXMOX_TOKEN_NAME=automation
PROXMOX_TOKEN_VALUE=<paste-token-here>
```

#### Alternative: Password Authentication

Less secure, but works:
```env
PROXMOX_HOST=192.168.1.185
PROXMOX_USER=root@pam
PROXMOX_PASSWORD=your-password-here
```

### SSL Certificate Options

**For self-signed certificates (default in most labs):**
```env
PROXMOX_VERIFY_SSL=false
```

**For valid SSL certificates (production):**
```env
PROXMOX_VERIFY_SSL=true
```

### SSH Configuration (Optional)

If you want direct server access:
```env
PROXMOX_SSH_HOST=192.168.1.185
PROXMOX_SSH_PORT=22
PROXMOX_SSH_USER=root
PROXMOX_SSH_KEY_PATH=/home/pxmgr/.ssh/id_rsa
```

Mount your SSH key:
```bash
docker-compose run --rm -v ~/.ssh:/home/pxmgr/.ssh:ro proxmox-platform shell
```

## 🚀 First Run

### Basic Commands

```bash
# Test connection
docker-compose run --rm proxmox-platform test

# List nodes
docker-compose run --rm proxmox-platform node list

# List VMs
docker-compose run --rm proxmox-platform vm list

# Show cluster status
docker-compose run --rm proxmox-platform status

# Interactive shell
docker-compose run --rm -it proxmox-platform shell

# View help
docker-compose run --rm proxmox-platform --help
```

### Using Make (Convenience)

If you have `make` installed:

```bash
make test          # Test connection
make node-list     # List nodes
make vm-list       # List VMs
make shell         # Interactive shell
make logs          # View logs
```

See `Makefile` for all available commands.

### Environment Variables

Set permanently by editing `.env`:
```env
PROXMOX_LOG_LEVEL=DEBUG
PXMGR_OUTPUT_FORMAT=json
```

Or pass temporarily:
```bash
docker-compose run \
  -e PXMGR_OUTPUT_FORMAT=json \
  proxmox-platform vm list
```

## ✅ Verification

### Connection Test

```bash
docker-compose run --rm proxmox-platform pxmgr selftest --verbose
```

Expected output shows:
- ✓ Python environment valid
- ✓ .env configuration loaded
- ✓ Connection to Proxmox successful
- ✓ API authentication valid
- ✓ Proxmox version detected

### Health Checks

```bash
docker-compose run --rm proxmox-platform health
```

Checks:
- Proxmox API connectivity
- Node status
- Storage accessibility
- Memory and CPU usage
- Disk usage

### First Operations

```bash
# Dry-run (preview without executing)
docker-compose run --rm proxmox-platform vm start 100 --dry-run

# List with JSON output
docker-compose run --rm proxmox-platform node list --output json

# With verbose logging
docker-compose run --rm proxmox-platform pxmgr --log-level DEBUG node list
```

## 🔧 Troubleshooting Installation

### Docker Not Found

```
docker: command not found
```

**Solution:**
- Install Docker Desktop from https://www.docker.com/products/docker-desktop
- Or install Docker Engine: https://docs.docker.com/engine/install/
- Restart terminal/system after installation

### Permission Denied

```
permission denied while trying to connect to Docker daemon
```

**Solution (Linux):**
```bash
sudo usermod -aG docker $USER
newgrp docker
```

**Solution (Windows/Mac):**
- Restart Docker Desktop
- Or run PowerShell as Administrator

### Port Already in Use

```
Error response from daemon: driver failed... port is already allocated
```

**Solution:**
```bash
# Find process using port 8006
lsof -i :8006  # macOS/Linux
netstat -ano | findstr :8006  # Windows

# Kill the process or change port in docker-compose.yml
```

### Build Fails

```
failed to solve with frontend dockerfile.v0
```

**Solution:**
```bash
# Clear Docker cache and rebuild
docker-compose build --no-cache --pull

# Or check internet connection and disk space
docker system df
```

### Connection Refused

```
Connection refused / Temporary failure in name resolution
```

**Check:**
1. Proxmox server is running: `ping 192.168.1.185`
2. Port 8006 is open: `telnet 192.168.1.185 8006`
3. Firewall allows connection
4. Correct PROXMOX_HOST in .env

### Authentication Failed

```
401 Unauthorized / Authentication failed
```

**Check:**
1. API token exists in Proxmox: Datacenter → Permissions → API Tokens
2. Token UUID is correct in .env
3. Token hasn't expired
4. Token has required permissions (PVEAdmin recommended for testing)

### SSL Certificate Errors

```
SSL: CERTIFICATE_VERIFY_FAILED / UNSAFE_LEGACY_RENEGOTIATION_DISABLED
```

**Solution:**
```env
# For self-signed certificates
PROXMOX_VERIFY_SSL=false
```

## 📚 Next Steps

After successful installation:

1. **Read the documentation:**
   - `README.md` - Complete feature overview
   - `QUICK-START.md` - Common command examples
   - `docs/` - Detailed guides

2. **Explore commands:**
   ```bash
   docker-compose run --rm proxmox-platform --help
   docker-compose run --rm proxmox-platform node --help
   docker-compose run --rm proxmox-platform vm --help
   ```

3. **Try operations:**
   ```bash
   # List nodes
   docker-compose run --rm proxmox-platform node list
   
   # List VMs
   docker-compose run --rm proxmox-platform vm list
   
   # Start VM (with dry-run first)
   docker-compose run --rm proxmox-platform vm start 100 --dry-run
   docker-compose run --rm proxmox-platform vm start 100
   ```

4. **Run setup wizard:**
   ```bash
   docker-compose run --rm -it proxmox-platform setup wizard
   ```

## 📞 Getting Help

- **Check logs**: `docker-compose logs proxmox-platform`
- **Verbose mode**: Add `--verbose` or `-v` flag
- **Test connection**: `docker-compose run --rm proxmox-platform test --verbose`
- **Issues**: https://github.com/bryansrevision/proxmox-personal-data-platform/issues
- **Proxmox docs**: https://pve.proxmox.com/wiki/Main_Page

## 🎉 Success!

Once you see ✓ in connection test, you're ready to:
- Manage Proxmox nodes and VMs
- Run automated discovery
- Track infrastructure changes
- Generate documentation
- Deploy services

See README.md and QUICK-START.md for complete usage documentation!

---

**Questions or issues?** Open an issue on GitHub or check the troubleshooting section.
