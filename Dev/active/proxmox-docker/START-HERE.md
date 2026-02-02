# 🐳 Proxmox Docker Platform - Setup Complete!

Your portable Docker container for the Proxmox Personal Data Platform is ready to use!

## 📁 What Was Created

```
proxmox-docker/
├── 📄 Dockerfile                    - Container build definition (multi-stage)
├── 📄 docker-compose.yml            - Service orchestration with volumes
├── 📄 docker-entrypoint.sh          - Smart startup script
├── 📄 .dockerignore                 - Build optimization
├── 📄 .env.example                  - Configuration template
├── 📄 .gitignore                    - Git exclusions
├── 📄 setup.sh                      - Linux/macOS setup script
├── 📄 setup.bat                     - Windows setup script
├── 📄 Makefile                      - Convenience commands
│
├── 📘 README.md                     - Complete documentation
├── 📘 QUICK-START.md                - Quick reference guide
├── 📘 INSTALLATION.md               - Detailed setup guide
├── 📘 THIS FILE                     - Overview
│
└── 📁 Directories (created on first run)
    ├── config/                      - Persistent configuration
    └── logs/                        - Application logs
```

## ⚡ Quick Start (Choose Your Path)

### Windows Users
```powershell
cd C:\Users\YourName\proxmox-docker
setup.bat
# Follow the prompts!
```

### macOS/Linux Users
```bash
cd ~/proxmox-docker
bash setup.sh
# Follow the prompts!
```

### Manual Setup (All Platforms)
```bash
cd proxmox-docker
cp .env.example .env
# Edit .env with your Proxmox credentials
docker-compose build
docker-compose run --rm proxmox-platform test
```

## 🔑 What You Need

Before running, gather your Proxmox info:

| Item | Example | Where to Find |
|------|---------|---------------|
| **Proxmox Host** | `192.168.1.185` | Your Proxmox server IP |
| **Proxmox User** | `root@pam` | Default user |
| **Token Name** | `automation` | Create in Proxmox UI |
| **Token Value** | `uuid-string` | Copy when creating token |

### Getting Your API Token (Recommended)

1. Open Proxmox web UI: `https://192.168.1.185:8006`
2. Go to: **Datacenter** → **Permissions** → **API Tokens**
3. Click "Add" and create a token named "automation"
4. **Copy the token value immediately** (shown only once!)
5. Add to `.env` file

## 🚀 First Commands

```bash
# Test connection
docker-compose run --rm proxmox-platform test

# List nodes
docker-compose run --rm proxmox-platform node list

# List VMs
docker-compose run --rm proxmox-platform vm list

# Interactive shell
docker-compose run --rm -it proxmox-platform shell
```

## 📚 Documentation Guide

| Document | Purpose |
|----------|---------|
| **README.md** | Complete feature guide & examples |
| **QUICK-START.md** | Command reference & common tasks |
| **INSTALLATION.md** | Detailed setup & troubleshooting |
| **docker-compose.yml** | Container configuration |
| **.env.example** | Configuration template |

## 🎯 Key Features

✅ **Portable** - Run on Windows, Mac, or Linux  
✅ **Lightweight** - Multi-stage build (~500MB)  
✅ **Secure** - Non-root user, SSL support, .env protection  
✅ **Easy Setup** - Automated scripts & compose  
✅ **Flexible** - Shell, Python REPL, or command mode  
✅ **Persistent** - Config & logs in mounted volumes  
✅ **Well-documented** - 3 guides + examples  

## 🛠️ Common Use Cases

### 1. One-Time Check
```bash
docker-compose run --rm proxmox-platform vm list
```

### 2. Regular Management
```bash
docker-compose up -d
# Services run in background
docker-compose logs -f
docker-compose down
```

### 3. Automation/Scripting
```bash
docker-compose run --rm proxmox-platform pxmgr --output json vm list
# Use output in scripts
```

### 4. Interactive Work
```bash
docker-compose run --rm -it proxmox-platform shell
# Use fully-featured bash environment
```

## 🔐 Security Checklist

- [ ] Created `.env` file with your credentials
- [ ] Set `.env` file permissions: `chmod 600 .env`
- [ ] Using API token (not password)
- [ ] Using HTTPS (PROXMOX_VERIFY_SSL=true for production)
- [ ] `.env` not committed to Git
- [ ] SSH key mounted read-only (if used)

## 📊 Container Details

| Aspect | Details |
|--------|---------|
| **Base Image** | Python 3.11-slim |
| **Image Size** | ~500MB |
| **Memory** | 100-300MB typical |
| **User** | Non-root (pxmgr) |
| **Volumes** | config, logs, .ssh |
| **Networking** | Bridge (172.28.0.0/16) |
| **Restart** | Unless stopped |

## 🚨 Troubleshooting

### Connection Fails
```bash
# Check if Proxmox is accessible
docker-compose run --rm proxmox-platform curl -k https://192.168.1.185:8006

# Check your .env file
cat .env
```

### SSL Certificate Errors
```bash
# For self-signed certificates:
# Edit .env and set:
PROXMOX_VERIFY_SSL=false
```

### Permission Issues
```bash
# Fix volume permissions
sudo chown -R $(id -u):$(id -g) config logs
```

### View Detailed Logs
```bash
docker-compose logs -f proxmox-platform
```

## 📞 Next Steps

1. **Follow INSTALLATION.md** - Step-by-step setup
2. **Edit your .env file** - Add Proxmox credentials
3. **Run `docker-compose build`** - Build image
4. **Test connection** - `docker-compose run --rm proxmox-platform test`
5. **Read README.md** - Learn all features

## 🎓 Learning Resources

- **Proxmox Docs**: https://pve.proxmox.com/wiki/
- **Docker Docs**: https://docs.docker.com/
- **pxmgr Help**: `docker-compose run --rm proxmox-platform --help`
- **GitHub**: https://github.com/bryansrevision/proxmox-personal-data-platform

## 💡 Pro Tips

### Use Make (if installed)
```bash
make build
make test
make shell
make logs
# See Makefile for all commands
```

### Environment Variables
```bash
# Set for single command
docker-compose run -e PXMGR_LOG_LEVEL=DEBUG proxmox-platform vm list

# Or add to .env for permanent setting
echo "PXMGR_LOG_LEVEL=DEBUG" >> .env
```

### Volume Mounting
```bash
# Mount custom scripts
docker-compose run \
  -v $(pwd)/my-scripts:/app/scripts:ro \
  proxmox-platform shell
```

### JSON Output for Scripting
```bash
# Get JSON output
docker-compose run --rm proxmox-platform vm list --output json

# Use in scripts
docker-compose run --rm proxmox-platform node list --output json | jq '.nodes'
```

## 🎉 Ready to Go!

Your Docker container is built and ready. Start with:

```bash
# Navigate to the directory
cd proxmox-docker

# Test your connection
docker-compose run --rm proxmox-platform test

# List your nodes
docker-compose run --rm proxmox-platform node list
```

See **README.md** for complete documentation and examples!

---

**Questions?** Check INSTALLATION.md for troubleshooting or open a GitHub issue.

**Made with ❤️ for Proxmox enthusiasts**
