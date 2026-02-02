# 📖 Proxmox Docker Platform - Documentation Index

Welcome! This directory contains everything you need to run Proxmox Personal Data Platform (`pxmgr`) in Docker on your local PC.

## 🎯 Quick Navigation

### Getting Started
- **[START-HERE.md](START-HERE.md)** ← **Read this first!**
  - Overview of what was created
  - Quick start commands
  - Security checklist
  - Common use cases

### Setup & Installation
- **[INSTALLATION.md](INSTALLATION.md)** - Detailed setup guide
  - Platform-specific instructions (Windows/Mac/Linux)
  - Getting Proxmox credentials
  - Configuration options
  - Troubleshooting

### Usage & Reference
- **[README.md](README.md)** - Complete feature documentation
  - All available commands
  - Examples for each feature
  - Advanced configuration
  - Docker advanced usage

- **[QUICK-START.md](QUICK-START.md)** - Command cheat sheet
  - Essential commands table
  - Common tasks
  - One-liners
  - Troubleshooting quick fixes

### Technical Details
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Technical deep dive
  - Container architecture diagram
  - Build process explanation
  - Security architecture
  - Performance optimization

## 📁 File Directory

### Core Docker Files
```
Dockerfile              - Container build definition (multi-stage)
docker-compose.yml      - Service orchestration & configuration
docker-entrypoint.sh    - Smart startup script with validation
.dockerignore           - Build context optimization
```

### Configuration Files
```
.env.example            - Configuration template (copy to .env)
.gitignore              - Git exclusions (don't commit secrets!)
Makefile                - Convenience commands (if make installed)
```

### Setup Scripts
```
setup.sh                - Automated setup for macOS/Linux
setup.bat               - Automated setup for Windows
```

### Documentation
```
START-HERE.md           - Quick overview (read first!)
INSTALLATION.md         - Step-by-step setup guide
README.md               - Complete feature documentation
QUICK-START.md          - Command reference & examples
ARCHITECTURE.md         - Technical architecture details
(this file)             - Documentation index
```

## 🚀 Getting Started (3 Steps)

### 1. Choose Your Setup Method

**Automated (Recommended):**
- Windows: `setup.bat`
- macOS/Linux: `bash setup.sh`

**Manual:**
```bash
cp .env.example .env
# Edit .env with your Proxmox details
docker-compose build
docker-compose run --rm proxmox-platform test
```

### 2. Configure Your Proxmox Connection

Edit `.env` with:
```env
PROXMOX_HOST=192.168.1.185        # Your Proxmox IP
PROXMOX_USER=root@pam             # Your user
PROXMOX_TOKEN_NAME=automation     # API token name
PROXMOX_TOKEN_VALUE=<uuid>        # API token value
PROXMOX_VERIFY_SSL=false          # For self-signed certs
```

### 3. Test & Run

```bash
# Test connection
docker-compose run --rm proxmox-platform test

# List nodes
docker-compose run --rm proxmox-platform node list

# Interactive shell
docker-compose run --rm -it proxmox-platform shell
```

## 📚 Documentation Guide

### For First-Time Users
1. Read **START-HERE.md** (5 min)
2. Follow **INSTALLATION.md** (15 min)
3. Run quick test commands from **QUICK-START.md**

### For Regular Usage
- Keep **QUICK-START.md** handy for common commands
- Refer to **README.md** for feature details
- Use `docker-compose run --rm proxmox-platform --help` for CLI help

### For Troubleshooting
1. Check **INSTALLATION.md** troubleshooting section
2. View logs: `docker-compose logs proxmox-platform`
3. Run verbose test: `docker-compose run --rm proxmox-platform test --verbose`

### For Technical Understanding
- Read **ARCHITECTURE.md** to understand how it works
- Review **docker-compose.yml** for container configuration
- Examine **Dockerfile** for build process

## 🎯 Common Tasks

### First-Time Setup
```bash
# Read overview
cat START-HERE.md

# Run setup script
bash setup.sh          # macOS/Linux
# or
setup.bat              # Windows
```

### Daily Operations
```bash
# Test connection
docker-compose run --rm proxmox-platform test

# List resources
docker-compose run --rm proxmox-platform node list
docker-compose run --rm proxmox-platform vm list

# Run command with options
docker-compose run --rm proxmox-platform vm list --output json
```

### Troubleshooting
```bash
# View logs
docker-compose logs proxmox-platform

# Test with verbose output
docker-compose run --rm proxmox-platform test --verbose

# Check configuration
cat .env

# Interactive debugging
docker-compose run --rm -it proxmox-platform shell
```

## 🔑 Key Files Explained

### `.env` File
- **Purpose**: Stores your Proxmox credentials
- **Usage**: Created from `.env.example`, never commit to git
- **Security**: Should have mode 600 (read-only for you)
- **Edit**: `nano .env` or open in your editor

### `docker-compose.yml`
- **Purpose**: Defines container services, volumes, networks
- **Edit if**: Need to change resource limits, ports, volumes
- **Default**: Usually works as-is

### `Dockerfile`
- **Purpose**: Instructions to build the container image
- **Edit if**: Want to customize the image
- **Structure**: Multi-stage build for optimization

### `docker-entrypoint.sh`
- **Purpose**: Smart startup script
- **Features**: Validates config, routes commands, shows help
- **Don't edit**: Usually works as-is

## 📊 What Gets Created

### At Build Time
```
Docker Image: proxmox-platform:latest (~500MB)
├── Python 3.11
├── pxmgr CLI
├── All dependencies
└── Non-root user
```

### At Runtime
```
Docker Container: proxmox-pxmgr
├── config/          - Configuration directory
├── logs/            - Application logs
└── Runtime state    - Infrastructure snapshots
```

## 🔐 Security Overview

✅ **What's Secure:**
- Non-root container execution
- Secrets in .env (not in code)
- SSL/TLS support
- Read-only secrets mounting
- No privilege escalation

⚠️ **Your Responsibility:**
- Create `.env` from template
- Add your credentials securely
- Don't commit `.env` to git
- Protect `.env` file (chmod 600)
- Rotate API tokens periodically

## 🆘 Getting Help

### Documentation
1. **START-HERE.md** - Quick overview & setup
2. **INSTALLATION.md** - Detailed setup & troubleshooting
3. **README.md** - Feature documentation
4. **QUICK-START.md** - Command reference

### Command Help
```bash
# Show all available commands
docker-compose run --rm proxmox-platform --help

# Show command-specific help
docker-compose run --rm proxmox-platform node --help
docker-compose run --rm proxmox-platform vm --help
```

### Debug Information
```bash
# Check Docker version
docker --version
docker-compose --version

# Verify installation
docker-compose run --rm proxmox-platform pxmgr --version

# Test connection
docker-compose run --rm proxmox-platform test --verbose

# View detailed logs
docker-compose logs -f proxmox-platform
```

### External Resources
- **Proxmox Docs**: https://pve.proxmox.com/wiki/
- **Docker Docs**: https://docs.docker.com/
- **GitHub Issues**: https://github.com/bryansrevision/proxmox-personal-data-platform/issues

## 📈 Feature Levels

### Beginner (Start Here)
- [ ] Read START-HERE.md
- [ ] Follow INSTALLATION.md
- [ ] Run first commands from QUICK-START.md
- [ ] List nodes/VMs

### Intermediate
- [ ] Learn all commands from README.md
- [ ] Use discovery features
- [ ] Run setup wizard
- [ ] Explore different output formats

### Advanced
- [ ] Read ARCHITECTURE.md
- [ ] Customize docker-compose.yml
- [ ] Write custom scripts
- [ ] Integrate with other tools

## 🎓 Learning Path

```
START-HERE.md (5 min)
    ↓
INSTALLATION.md (15 min)
    ↓
Run simple commands (5 min)
    ↓
QUICK-START.md (reference)
    ↓
README.md (explore features)
    ↓
ARCHITECTURE.md (understand internals)
    ↓
Advanced usage & customization
```

## ✅ Checklist

### Initial Setup
- [ ] Read START-HERE.md
- [ ] Install Docker
- [ ] Clone/download repository
- [ ] Copy .env.example to .env
- [ ] Edit .env with your Proxmox info
- [ ] Run setup script or docker-compose build
- [ ] Test connection: `docker-compose run --rm proxmox-platform test`

### Ongoing Usage
- [ ] Keep .env secure (chmod 600)
- [ ] Don't commit .env to git
- [ ] Rotate API tokens periodically
- [ ] Monitor logs for errors
- [ ] Keep Docker images updated

### Security
- [ ] .env file created and protected
- [ ] Using API token (not password)
- [ ] SSH key mounted read-only (if used)
- [ ] .env not in version control
- [ ] Firewall allows Proxmox access

## 📞 Support

### Common Issues
- **Connection refused**: Check PROXMOX_HOST and firewall
- **SSL error**: Set PROXMOX_VERIFY_SSL=false for self-signed certs
- **Permission denied**: Run `chmod 600 .env`
- **Container won't start**: Check logs: `docker-compose logs`

### Get Help
1. Check **INSTALLATION.md** troubleshooting
2. View logs: `docker-compose logs proxmox-platform`
3. Test manually: `docker-compose run --rm proxmox-platform test --verbose`
4. Open GitHub issue with logs and configuration (sanitized)

## 🎉 Ready to Begin?

**Start here:** Read **START-HERE.md** for overview and quick setup instructions!

---

## 📋 File Manifest

| File | Size | Purpose |
|------|------|---------|
| Dockerfile | 2.3KB | Container build definition |
| docker-compose.yml | 1.7KB | Service orchestration |
| docker-entrypoint.sh | 6.4KB | Startup script |
| .dockerignore | 0.4KB | Build optimization |
| .env.example | 3.1KB | Config template |
| setup.sh | 3.8KB | Linux/Mac setup |
| setup.bat | 2.5KB | Windows setup |
| Makefile | 3.1KB | Convenience commands |
| .gitignore | 0.1KB | Git exclusions |
| START-HERE.md | 6.9KB | Quick overview |
| INSTALLATION.md | 11.8KB | Detailed setup |
| README.md | 12.0KB | Feature docs |
| QUICK-START.md | 2.4KB | Command reference |
| ARCHITECTURE.md | 10.7KB | Technical details |

**Total Documentation:** ~67KB  
**Total Docker Setup:** ~28KB  
**Setup Scripts:** ~6KB

---

**Questions?** Start with START-HERE.md or INSTALLATION.md!

**Made with ❤️ for Proxmox enthusiasts**
