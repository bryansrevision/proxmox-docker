# 🎯 Proxmox Docker Platform - User Guide Summary

**Location:** `C:\Users\Dylan\proxmox-docker\`

## What You Have

A **portable, production-ready Docker container** for running Proxmox Personal Data Platform (`pxmgr`) on your Windows/Mac/Linux PC.

### Package Contents (15 Files)

**Docker Configuration:**
- `Dockerfile` - Multi-stage optimized build (500MB final image)
- `docker-compose.yml` - Complete service orchestration
- `docker-entrypoint.sh` - Smart startup with validation
- `.dockerignore` - Build optimization

**Setup & Configuration:**
- `setup.bat` - Windows automated setup
- `setup.sh` - macOS/Linux automated setup
- `.env.example` - Configuration template
- `.gitignore` - Git security (don't commit .env!)

**Tools & Utilities:**
- `Makefile` - Convenience commands (if `make` is installed)

**Documentation (6 Guides):**
1. `INDEX.md` - Documentation index & navigation
2. `START-HERE.md` - Quick overview (5 min read)
3. `INSTALLATION.md` - Detailed setup guide
4. `README.md` - Complete feature documentation
5. `QUICK-START.md` - Command reference cheat sheet
6. `ARCHITECTURE.md` - Technical deep dive

## 🚀 Getting Started (3 Options)

### Option 1: Automated Setup (Easiest)

**Windows:**
```cmd
cd C:\Users\Dylan\proxmox-docker
setup.bat
```

**macOS/Linux:**
```bash
cd ~/proxmox-docker
bash setup.sh
```

The script will:
- Check Docker installation ✓
- Create `.env` file ✓
- Edit configuration ✓
- Build Docker image ✓
- Show next steps ✓

### Option 2: Manual Setup (Step-by-Step)

```bash
# Navigate to directory
cd C:\Users\Dylan\proxmox-docker

# Copy configuration template
copy .env.example .env

# Edit with your Proxmox details
notepad .env    # Windows
# or
nano .env       # macOS/Linux

# Build the Docker image
docker-compose build

# Test connection
docker-compose run --rm proxmox-platform test
```

### Option 3: Using Make (Quick)

```bash
make build   # Build image
make test    # Test connection
make node-list  # List nodes
```

## 📋 What You Need

Before running, gather:
| Item | Example |
|------|---------|
| Proxmox IP | `192.168.1.185` |
| Proxmox User | `root@pam` |
| API Token Name | `automation` |
| API Token Value | `uuid-string` |

**Getting an API Token:**
1. Open Proxmox UI: `https://192.168.1.185:8006`
2. Go to: Datacenter → Permissions → API Tokens
3. Click "Add" and create token
4. **Copy immediately** (shown only once!)

## 🎯 First Commands

```bash
# Test connection
docker-compose run --rm proxmox-platform test

# List nodes
docker-compose run --rm proxmox-platform node list

# List VMs
docker-compose run --rm proxmox-platform vm list

# Interactive shell
docker-compose run --rm -it proxmox-platform shell

# Show all commands
docker-compose run --rm proxmox-platform --help
```

## 📚 Which Doc to Read?

| Need | Read |
|------|------|
| Quick overview | **START-HERE.md** |
| Step-by-step setup | **INSTALLATION.md** |
| Common commands | **QUICK-START.md** |
| All features | **README.md** |
| How it works | **ARCHITECTURE.md** |
| Navigate docs | **INDEX.md** |

## 🔒 Security Checklist

- [ ] Created `.env` file
- [ ] Added your Proxmox credentials
- [ ] Set `.env` permissions: `chmod 600 .env`
- [ ] Not committing `.env` to git
- [ ] Using API token (not password)

## 🆘 Quick Troubleshooting

**Docker not found?**
- Install Docker Desktop: https://www.docker.com/products/docker-desktop

**Connection fails?**
- Check PROXMOX_HOST in .env is correct
- Verify Proxmox is reachable: `ping 192.168.1.185`

**SSL errors?**
- For self-signed certs, set: `PROXMOX_VERIFY_SSL=false`

**Permission denied?**
- Run: `chmod 600 .env`

**Can't build image?**
- Check Docker is running
- Try: `docker-compose build --no-cache --pull`

See **INSTALLATION.md** for detailed troubleshooting.

## 💾 After Setup

### Running Commands
```bash
# One-time commands
docker-compose run --rm proxmox-platform node list

# Long-running service
docker-compose up -d
docker-compose logs -f

# Clean up
docker-compose down
```

### Configuration
- All config in `.env` file
- Change environment variables anytime
- Restart container to apply changes

### Persistence
- `/config` - Configuration files (survives restart)
- `/logs` - Application logs (survives restart)

## 🌟 Key Features

✅ **Portable** - Windows/Mac/Linux  
✅ **Secure** - Non-root user, secrets in .env  
✅ **Efficient** - 500MB optimized image  
✅ **Complete** - CLI, shell, Python REPL  
✅ **Documented** - 6 comprehensive guides  
✅ **Automated** - Setup scripts, health checks  

## 📊 System Requirements

- Docker Desktop or Docker Engine
- 2GB RAM minimum (4GB recommended)
- 1GB disk space for image + config
- Network access to Proxmox server

## 🚀 Next Steps

1. **Read INDEX.md** - Documentation navigation
2. **Read START-HERE.md** - Quick overview
3. **Run setup script** - Automated setup
4. **Edit .env** - Add your credentials
5. **Test connection** - `docker-compose run --rm proxmox-platform test`
6. **Run commands** - Use pxmgr for management

## 💡 Pro Tips

### Use Aliases (Linux/Mac)
```bash
alias pxmgr="docker-compose run --rm proxmox-platform"
pxmgr node list
```

### Use Make
```bash
make test       # Test connection
make node-list  # List nodes
make shell      # Interactive shell
make logs       # View logs
```

### JSON Output (for scripting)
```bash
docker-compose run --rm proxmox-platform vm list --output json
```

## 📖 Learning Path

```
START-HERE.md (5 min) →
  ↓
INSTALLATION.md (15 min) →
  ↓
Run test command (2 min) →
  ↓
QUICK-START.md (reference) →
  ↓
README.md (explore) →
  ↓
ARCHITECTURE.md (understand) →
  ↓
Advanced customization
```

## 🎓 Understanding the Setup

### What Gets Installed
- Python 3.11 environment
- Proxmox management CLI (`pxmgr`)
- All dependencies
- SSH client, Git, nano, vim

### What Gets Created
- Docker image `proxmox-platform:latest`
- Docker container `proxmox-pxmgr`
- Volumes for config/logs
- Network bridge

### How It Works
1. You edit `.env` with credentials
2. Docker loads environment variables
3. Entrypoint script validates config
4. Command is routed to appropriate handler
5. Output is displayed to terminal
6. Container exits (or runs interactive shell)

## 🔐 Security Model

**Your Credentials:**
- Store in `.env` file only
- Never commit to git
- Protected file permissions (600)

**Container Security:**
- Runs as non-root user (pxmgr)
- No privilege escalation
- Read-only secret mounts
- SSL/TLS support

**API Token:**
- More secure than passwords
- Can be revoked instantly
- Supports limited permissions
- Can set expiration dates

## 📞 Getting Help

**Documentation:**
- INDEX.md - Documentation guide
- INSTALLATION.md - Setup troubleshooting
- README.md - Feature documentation
- QUICK-START.md - Command examples

**Command Help:**
```bash
docker-compose run --rm proxmox-platform --help
docker-compose run --rm proxmox-platform node --help
```

**Debug Info:**
```bash
docker-compose logs proxmox-platform
docker-compose run --rm proxmox-platform test --verbose
```

**External:**
- Proxmox Docs: https://pve.proxmox.com/wiki/
- Docker Docs: https://docs.docker.com/
- GitHub Issues: https://github.com/bryansrevision/proxmox-personal-data-platform/issues

## ✅ Success Indicators

You'll know setup is complete when:

1. ✅ Docker image builds successfully
2. ✅ Container starts without errors
3. ✅ Connection test passes: `[SUCCESS] API accessible`
4. ✅ Can list nodes: `docker-compose run --rm proxmox-platform node list`
5. ✅ Can list VMs: `docker-compose run --rm proxmox-platform vm list`

## 🎉 You're Ready!

Once setup is complete, you have a portable, production-ready tool for:
- Managing Proxmox nodes and VMs
- Infrastructure discovery
- Change tracking
- Documentation generation
- Service deployment
- Automation

Use it on your PC, at the office, at home, anywhere with Docker!

---

**Questions?** Read INDEX.md for documentation links or check INSTALLATION.md troubleshooting.

**Made with ❤️ for Proxmox enthusiasts**
