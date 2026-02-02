# Docker Architecture & Technical Details

## 📐 Container Architecture

```
┌──────────────────────────────────────────────────────────┐
│                   Docker Container                        │
│                  (proxmox-platform)                       │
├──────────────────────────────────────────────────────────┤
│                                                            │
│  ┌────────────────────────────────────────────────────┐  │
│  │         Application Layer (pxmgr CLI)              │  │
│  │  - Node management      - VM operations           │  │
│  │  - Discovery engine     - Change tracking         │  │
│  │  - Documentation gen    - Setup wizard            │  │
│  └────────────────────────────────────────────────────┘  │
│                           ↓                               │
│  ┌────────────────────────────────────────────────────┐  │
│  │    Framework Layer (Typer, Rich, Pydantic)         │  │
│  │  - CLI parsing & routing  - Output formatting    │  │
│  │  - Data validation        - Terminal UI           │  │
│  └────────────────────────────────────────────────────┘  │
│                           ↓                               │
│  ┌────────────────────────────────────────────────────┐  │
│  │      API Client Layer (Proxmoxer + requests)       │  │
│  │  - HTTP communication   - Authentication         │  │
│  │  - Session management   - Error handling         │  │
│  └────────────────────────────────────────────────────┘  │
│                           ↓                               │
│  ┌────────────────────────────────────────────────────┐  │
│  │           System Libraries (Python 3.11)           │  │
│  │  - Standard library  - Third-party packages       │  │
│  │  - OpenSSL           - CA certificates            │  │
│  └────────────────────────────────────────────────────┘  │
│                           ↓                               │
│  ┌────────────────────────────────────────────────────┐  │
│  │         Base Image (Debian slim)                   │  │
│  │  - Linux kernel      - System utilities            │  │
│  │  - Package manager   - Shell (bash)                │  │
│  └────────────────────────────────────────────────────┘  │
│                                                            │
├──────────────────────────────────────────────────────────┤
│                   Mounted Volumes                         │
├──────────────────────────────────────────────────────────┤
│  /app/config          - Configuration & state            │
│  /app/logs            - Application logs                 │
│  /home/pxmgr/.ssh     - SSH keys (optional)              │
│  /home/pxmgr/.config  - User config                      │
└──────────────────────────────────────────────────────────┘
```

## 🏗️ Build Process (Multi-Stage)

### Stage 1: Builder
```dockerfile
FROM python:3.11-slim as builder
- Install build dependencies (gcc, git, etc.)
- Create virtual environment
- Install all Python packages
- Result: ~800MB intermediate layer (discarded)
```

### Stage 2: Runtime
```dockerfile
FROM python:3.11-slim
- Copy only virtual environment from builder
- Install runtime dependencies only (curl, git, ssh)
- Copy application code
- Create non-root user
- Result: ~500MB final image
```

**Benefits:**
- 60% smaller than single-stage build
- No build tools in final image
- Faster builds on subsequent runs
- Better security (fewer attack vectors)

## 🔄 Execution Flow

```
┌─────────────────────────┐
│  Docker Run Command     │
│  (user input)           │
└────────────┬────────────┘
             ↓
┌─────────────────────────┐
│  docker-entrypoint.sh   │
│  - Load .env            │
│  - Validate config      │
│  - Route command        │
└────────────┬────────────┘
             ↓
┌─────────────────────────────────────────────┐
│  Command Router                             │
├─────────────────────────────────────────────┤
│  test/selftest      → pxmgr selftest       │
│  node/vm/api        → pxmgr [command]      │
│  shell/bash         → /bin/bash             │
│  python/py          → python REPL           │
│  script             → python script.py      │
│  help/--help        → Show help text        │
│  [other]            → pxmgr [command]      │
└────────────┬────────────────────────────────┘
             ↓
┌─────────────────────────┐
│  Application Execution  │
│  Generates output/logs  │
└────────────┬────────────┘
             ↓
┌─────────────────────────┐
│  Exit with status code  │
│  0 = success            │
│  1+ = error             │
└─────────────────────────┘
```

## 🔐 Security Architecture

### User Isolation
```dockerfile
RUN groupadd -r pxmgr && useradd -r -g pxmgr pxmgr
USER pxmgr
```
- Container runs as non-root user
- Prevents privilege escalation
- Files owned by pxmgr user

### Capabilities
```dockerfile
security_opt:
  - no-new-privileges:true
```
- No capability escalation
- Kernel hardening
- Cannot gain elevated privileges

### Volume Security
```yaml
volumes:
  - ~/.ssh:/home/pxmgr/.ssh:ro  # Read-only mount
```
- SSH keys mounted read-only
- Configuration mounted read-only
- Only config directory is writable

### Secret Management
```
NEVER log credentials in output:
- API tokens masked
- Passwords never echoed
- Secrets in .env (not committed)
- No debug output of sensitive data
```

## 📊 Resource Management

### Memory Management
```yaml
deploy:
  resources:
    limits:
      memory: 1G         # Hard limit
    reservations:
      memory: 512M       # Soft limit
```

### CPU Management
```yaml
deploy:
  resources:
    limits:
      cpus: '2'          # Max 2 CPUs
    reservations:
      cpus: '1'          # Reserve 1 CPU
```

### Restart Policy
```yaml
restart: unless-stopped
```
- Auto-restart on failure
- Unless explicitly stopped
- Prevents zombie processes

## 🌐 Network Architecture

### Docker Network
```yaml
networks:
  proxmox-net:
    driver: bridge
    ipam:
      config:
        - subnet: 172.28.0.0/16
```

### Network Flow
```
┌──────────────────┐
│  Container       │
│  172.28.0.2      │
└────────┬─────────┘
         │
    Docker Bridge
    172.28.0.0/16
         │
┌────────┴──────────┐
│  Host Network     │
│  10.0.0.0/8       │
└────────┬──────────┘
         │
    Host Firewall
         │
┌────────┴──────────────────┐
│  Proxmox Server           │
│  192.168.1.185:8006       │
└───────────────────────────┘
```

## 📦 Volume Structure

### config/ Directory
```
config/
├── .env              - Configuration (generated at runtime)
├── state/            - Infrastructure state (JSON)
├── templates/        - VM templates
├── backups/          - Backup metadata
└── git-tracking/     - Git repo for change tracking
```

### logs/ Directory
```
logs/
├── pxmgr.log         - Application logs
├── api.log           - API communication logs
├── error.log         - Error logs
└── archive/          - Rotated old logs
```

## 🔄 Data Persistence

### Mounted Volumes
```
Docker Container              Host System
┌──────────────────┐         ┌──────────────────┐
│ /app/config ────────────→ ./config/          │
│ /app/logs ──────────────→ ./logs/            │
│ ~/.ssh ─────────────────→ ~/.ssh/ (ro)       │
│ /.env ──────────────────→ ./.env (ro)        │
└──────────────────┘         └──────────────────┘
```

## 🏥 Health Check

```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD pxmgr --help > /dev/null || exit 1
```

- Runs every 30 seconds
- Times out after 10 seconds
- Allows 5 seconds to start
- Retries 3 times before marking unhealthy

## 📝 Logging Configuration

### docker-compose.yml
```yaml
logging:
  driver: json-file
  options:
    max-size: "10m"      # Rotate at 10MB
    max-file: "3"        # Keep 3 files
```

### Log Levels
```env
PXMGR_LOG_LEVEL=INFO    # INFO, DEBUG, WARNING, ERROR
```

## 🎯 Entrypoint Script Flow

```bash
1. Set error handling (set -e)
2. Initialize colors for output
3. Create directories (config, logs)
4. Check if .env exists
   → If not, copy from .env.example
5. Source .env (load environment)
6. Validate required variables:
   - PROXMOX_HOST (required)
   - PROXMOX_USER (required)
   - PROXMOX_TOKEN_NAME or PROXMOX_PASSWORD (required)
7. Log execution info
8. Parse command from $1
9. Route to handler:
   - selftest/test/health → pxmgr command
   - shell/bash/sh → /bin/bash
   - python/py → python REPL
   - script → python script.py
   - help → show help text
   - default → pxmgr command
10. Execute with exec (replaces shell process)
```

## 🔌 Extension Points

### Custom Scripts
```bash
# Mount custom scripts directory
docker-compose run \
  -v $(pwd)/scripts:/app/scripts:ro \
  proxmox-platform script /app/scripts/my-script.py arg1 arg2
```

### Additional Volumes
```yaml
volumes:
  - ./config:/app/config
  - ./data:/app/data
  - ./custom:/app/custom:ro
```

### Environment Extensions
```env
# Add custom environment variables
MY_CUSTOM_VAR=value
MY_SCRIPT_SETTING=enabled
```

## 🚀 Performance Optimization

### Image Size Optimization
- Multi-stage build: ~60% size reduction
- Slim base image: Minimal OS footprint
- .dockerignore: Excludes unnecessary files
- Dependency cleanup: Removes cache after install

### Build Optimization
```dockerfile
# Layer caching
COPY requirements.txt .        # Cache often
RUN pip install -r requirements.txt

COPY src/ /app/src/           # Cache rarely
```

### Runtime Optimization
- Virtual environment used (no global packages)
- Non-root user (lighter permissions)
- Minimal dependencies (only what's needed)
- No build tools in runtime

## 📊 Comparison: Direct Install vs Docker

| Aspect | Direct Install | Docker |
|--------|---|---|
| Setup Time | 10-20 min | 5 min (first) |
| Isolation | Limited | Complete |
| Python Version | System default | Guaranteed 3.11 |
| Dependency Conflicts | Possible | None |
| Multiple Versions | Complex | Simple |
| Cleanup | Manual | One command |
| Portability | OS-specific | Universal |
| Resource Limits | Manual | Built-in |

---

**This architecture ensures:**
- ✅ Security (non-root, read-only secrets)
- ✅ Portability (works everywhere Docker runs)
- ✅ Reliability (health checks, auto-restart)
- ✅ Performance (optimized image, resource limits)
- ✅ Maintainability (clean separation, documented)
