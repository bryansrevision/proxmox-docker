# 📚 Workspace Layout & Navigation Guide

**Last Updated:** January 31, 2026  
**Status:** ✅ Production Ready

## 🗂️ Workspace Structure Overview

```
Home Workspace
│
├── 🏠 Home Assistant Unified (Active Project)
│   ├── config/
│   │   ├── secrets.yaml          ← Credentials (DO NOT COMMIT)
│   │   ├── configuration.yaml    ← Main configuration
│   │   └── secrets.yaml.template ← Template reference
│   ├── integrations/
│   │   ├── ifttt-webhooks.yaml
│   │   ├── alexa-integration.yaml
│   │   ├── google-home-integration.yaml
│   │   ├── smartthings-integration.yaml
│   │   └── apple-homekit-integration.yaml
│   ├── core/
│   │   └── automations/          ← Automation configs
│   ├── scripts/
│   │   ├── align-server.py       ← MCP sync script
│   │   ├── deploy-verify.ps1     ← Windows verification
│   │   └── deploy-verify.sh      ← Unix verification
│   ├── docs/
│   │   └── IFTTT-SETUP-GUIDE.md  ← Webhook documentation
│   ├── DEPLOYMENT-READY.md       ← Status & next steps
│   ├── DEPLOYMENT-COMPLETE-REPORT.md
│   ├── IMPLEMENTATION-COMPLETE.md
│   └── .env                      ← Environment vars (DO NOT COMMIT)
│
├── 🖥️ Proxmox Docker Platform
│   ├── docker-compose.yml        ← Container services
│   ├── Dockerfile                ← Container image
│   ├── .env                      ← Proxmox credentials
│   ├── config/                   ← Service configs
│   └── scripts/
│
├── 🗄️ Proxmox Documentation
│   ├── README.md
│   ├── API-EXAMPLES.md
│   └── GUIDES/
│
├── 📊 Proxmox Personal Data Platform
│   ├── README.md
│   ├── requirements.txt
│   ├── src/                      ← Source code
│   ├── scripts/                  ← Utility scripts
│   ├── docs/
│   └── docker-compose/           ← Local deployment
│
└── 🛠️ Tools & Utilities
    ├── SSH Configuration
    ├── Network Scanning Tools
    └── Automation Scripts
```

## 🎯 Quick Access By Task

### 🏠 Home Assistant Tasks

**Starting Services**

```bash
# Start Home Assistant with Docker
Task: "🏠 Home Assistant: Start Services"

# Or manually
cd c:\Users\Dylan\Dev\.WorkSpace\HomeAssistant\home-assistant-unified
docker-compose up -d
```

**Monitoring & Logs**

```bash
# View real-time logs
Task: "🏠 Home Assistant: View Logs"

# Or manually
docker-compose logs -f --tail=100
```

**Testing Connectivity**

```bash
# Run health check
Task: "🏠 Home Assistant: Health Check"

# Or manually
python test_ha_connection.py
```

**Deployment Verification**

```bash
# Run verification script
Task: "📊 Deploy Verification: Home Assistant"

# Or manually
powershell -ExecutionPolicy Bypass -File scripts/deploy-verify.ps1
```

### 🖥️ Proxmox Management

**Check System Status**

```bash
Task: "🖥️ Proxmox: System Status"

# Shows: Disk usage, Memory, Uptime, Service status
```

**List Infrastructure**

```bash
Task: "🖥️ Proxmox: List VMs"
Task: "🖥️ Proxmox: List Containers"
```

**API Check**

```bash
Task: "🖥️ Proxmox: API Status Check"
```

### 🐳 Docker Services

**Manage Services**

```bash
Task: "🐳 Docker: Start All Services"     # Start
Task: "🐳 Docker: Stop All Services"      # Stop
Task: "🐳 Docker: View Container Status"  # Status
Task: "🐳 Docker: View Logs"              # Logs
```

### 🔌 IFTTT Integration

**Test Webhook**

```bash
Task: "🔌 Test IFTTT Webhook"

# Expected Response: "Congratulations! You've fired the test event"
```

**Key Details**

```
Account:       bryansrevision_ulefone
Status:        ACTIVE ✅
Webhook Key:   bP_UORzOKD-9wjLYvfWanHbCuwIgaDXSxv2NfAtLM5Y
URL:           https://maker.ifttt.com/use/bP_UORzOKD-9wjLYvfWanHbCuwIgaDXSxv2NfAtLM5Y
```

### 📦 Python Development

**Environment Setup**

```bash
Task: "📦 Python: Create Virtual Environment"
Task: "📦 Python: Install Requirements"
```

**Testing**

```bash
Task: "🧪 Python: Run Tests"
```

**Code Quality**

```bash
Task: "✨ Format: All Python Files"    # Auto-format
Task: "🔧 Lint: Check Python Code"    # Check style
```

### 🔍 Git & Repository

**Repository Status**

```bash
Task: "🔍 Workspace: Check Git Status"
Task: "🔍 Workspace: Git Pull All Repos"
```

## 📖 Important Documents

### Status & Deployment

| Document | Location | Purpose |
|----------|----------|---------|
| **Deployment Ready** | `DEPLOYMENT-READY.md` | Next steps & checklist |
| **Deployment Report** | `DEPLOYMENT-COMPLETE-REPORT.md` | Full deployment details |
| **Implementation** | `IMPLEMENTATION-COMPLETE.md` | Completion summary |
| **Summary** | `DEPLOYMENT-SUMMARY-OUTPUT.txt` | Console output summary |

### Configuration & Setup

| Document | Location | Purpose |
|----------|----------|---------|
| **IFTTT Setup** | `docs/IFTTT-SETUP-GUIDE.md` | Webhook configuration |
| **Secrets Template** | `config/secrets.yaml.template` | Credential reference |
| **Configuration** | `core/configuration.yaml` | Main HA config |

### Integration Guides

| Integration | File | Status |
|-------------|------|--------|
| **IFTTT** | `integrations/ifttt-webhooks.yaml` | ✅ Active |
| **Alexa** | `integrations/alexa-integration.yaml` | ✅ Ready |
| **Google Home** | `integrations/google-home-integration.yaml` | ✅ Ready |
| **SmartThings** | `integrations/smartthings-integration.yaml` | ✅ Ready |
| **Apple HomeKit** | `integrations/apple-homekit-integration.yaml` | ✅ Ready |

## 🔐 Sensitive Files (DO NOT COMMIT)

```
config/secrets.yaml          ← Real credentials
.env                         ← Environment variables
.venv/                       ← Virtual environment
*.log                        ← Log files
known_devices.yaml          ← Device history
```

✅ **Properly Excluded by .gitignore**

## 🚀 Common Workflows

### Workflow 1: Deploy & Verify

```
1. Task: "🏠 Home Assistant: Start Services"
2. Wait 2-3 minutes
3. Task: "🏠 Home Assistant: Health Check"
4. Task: "📊 Deploy Verification: Home Assistant"
5. Access UI: http://192.168.1.201:8123
```

### Workflow 2: Check Infrastructure

```
1. Task: "🖥️ Proxmox: System Status"
2. Task: "🖥️ Proxmox: List VMs"
3. Task: "🖥️ Proxmox: List Containers"
4. Task: "🐳 Docker: View Container Status"
```

### Workflow 3: Test IFTTT Integration

```
1. Task: "🔌 Test IFTTT Webhook"
2. Check: https://ifttt.com/activity
3. Create test applet in IFTTT
4. Test bidirectional flow
```

### Workflow 4: Git Operations

```
1. Make changes in your files
2. Task: "🔍 Workspace: Check Git Status"
3. Commit changes: git add -A && git commit -m "message"
4. Task: "🔍 Workspace: Git Pull All Repos"
```

## 📊 System Endpoints

### Primary Services

```
Home Assistant:     http://192.168.1.201:8123
Proxmox:            https://192.168.1.185:8006
IFTTT Activity:     https://ifttt.com/activity
Webhook URL:        https://maker.ifttt.com/use/bP_UORzOKD-9wjLYvfWanHbCuwIgaDXSxv2NfAtLM5Y
```

### Configuration

```
Main Config:        core/configuration.yaml
IFTTT Config:       integrations/ifttt-webhooks.yaml
Secrets Location:   config/secrets.yaml (NOT IN GIT)
Environment:        .env (NOT IN GIT)
```

## 🔧 Required Tools & Installed

### Essential

- ✅ Python 3.8+
- ✅ Docker & Docker Compose
- ✅ Git
- ✅ SSH Client
- ✅ curl / wget
- ✅ VS Code

### Optional But Recommended

- PostgreSQL (for data persistence)
- MQTT Broker (for device communication)
- InfluxDB (for time-series data)
- Grafana (for visualization)

## 📝 File Size Reference

```
Home Assistant Configs:       ~2 MB
Integration Files:            ~500 KB
Documentation:                ~1 MB
Docker Compose Files:         ~100 KB
Scripts & Tools:              ~200 KB
─────────────────────────────────────
Total Project Size:           ~3-4 MB
```

## ✅ Verification Checklist

Before deploying:

- [ ] Review `config/secrets.yaml` for your credentials
- [ ] Update `.env` with custom API keys if needed
- [ ] Run: `Task: "📊 Deploy Verification: Home Assistant"`
- [ ] Verify all green checks ✅
- [ ] Check git status: `Task: "🔍 Workspace: Check Git Status"`
- [ ] Ready to restart Home Assistant

## 🎓 Documentation Index

**For Setup Help:**

1. Start: `DEPLOYMENT-READY.md`
2. Setup: `docs/IFTTT-SETUP-GUIDE.md`
3. Reference: `config/secrets.yaml.template`

**For Troubleshooting:**

1. Check logs: `Task: "🏠 Home Assistant: View Logs"`
2. Verify health: `Task: "🏠 Home Assistant: Health Check"`
3. System status: `Task: "🖥️ Proxmox: System Status"`

**For Development:**

1. Tests: `Task: "🧪 Python: Run Tests"`
2. Lint: `Task: "🔧 Lint: Check Python Code"`
3. Format: `Task: "✨ Format: All Python Files"`

## 🎯 Next Steps

1. **Review**: Check `DEPLOYMENT-READY.md`
2. **Verify**: Run deployment verification task
3. **Configure**: Update credentials in `config/secrets.yaml`
4. **Deploy**: Restart Home Assistant
5. **Test**: Run IFTTT webhook test
6. **Monitor**: Check logs and status

**Ready to Use!** 🚀

All workspace organization complete. Use the Tasks (Ctrl+Shift+B) to access
common operations.
