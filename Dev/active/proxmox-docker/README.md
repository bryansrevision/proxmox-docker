# Proxmox Personal Data Platform - Docker Setup

This directory contains a **portable, production-ready Docker container** for running the Proxmox Personal Data Platform (`pxmgr`) on your local PC.

## 📦 Contents

- **Dockerfile** - Multi-stage build for minimal image (~500MB)
- **docker-compose.yml** - Orchestration with proper configuration
- **docker-entrypoint.sh** - Smart entry point script with validation
- **.dockerignore** - Efficient build context

## 🚀 Quick Start

### Prerequisites

- Docker Desktop (Windows/Mac) or Docker Engine (Linux)
- Docker Compose (usually included with Docker Desktop)
- Your Proxmox credentials (IP, user, token/password)

### 1. Clone and Setup

```bash
# Clone the repository
git clone https://github.com/bryansrevision/proxmox-personal-data-platform.git
cd proxmox-personal-data-platform

# Copy this Docker directory to your local setup location
cp -r docker /path/to/proxmox-docker
cd /path/to/proxmox-docker
```

### 2. Configure Credentials

```bash
# Copy and edit environment file
cp .env.example .env

# Edit with your Proxmox details
# Required:
#   PROXMOX_HOST=192.168.1.185 (or your server IP)
#   PROXMOX_USER=root@pam
#   PROXMOX_TOKEN_NAME=automation
#   PROXMOX_TOKEN_VALUE=<your-token-uuid>
```

### 3. Build the Image

```bash
# Build locally (first time or after changes)
docker-compose build

# Or pull pre-built image (when available)
# docker pull bryansrevision/proxmox-platform:latest
```

### 4. Run Commands

```bash
# Test connection
docker-compose run --rm proxmox-platform selftest

# List nodes
docker-compose run --rm proxmox-platform node list

# List VMs
docker-compose run --rm proxmox-platform vm list

# Interactive shell
docker-compose run --rm -it proxmox-platform shell

# Run custom command
docker-compose run --rm proxmox-platform pxmgr --help
```

## 🎯 Usage Examples

### Basic Commands

```bash
# Test Proxmox connection
docker-compose run --rm proxmox-platform test

# Show Proxmox status
docker-compose run --rm proxmox-platform status

# Run health checks
docker-compose run --rm proxmox-platform health
```

### Node Management

```bash
# List all nodes
docker-compose run --rm proxmox-platform node list

# Get node details
docker-compose run --rm proxmox-platform node info pve

# Check node storage
docker-compose run --rm proxmox-platform node storage pve
```

### VM Operations

```bash
# List all VMs
docker-compose run --rm proxmox-platform vm list

# List running VMs only
docker-compose run --rm proxmox-platform vm list --status running

# Start a VM (dry-run first)
docker-compose run --rm proxmox-platform vm start 100 --dry-run

# Actually start the VM
docker-compose run --rm proxmox-platform vm start 100
```

### Infrastructure Discovery

```bash
# Initialize discovery
docker-compose run --rm proxmox-platform discover init

# Scan infrastructure
docker-compose run --rm proxmox-platform discover scan

# Scan specific components
docker-compose run --rm proxmox-platform discover scan --hardware
docker-compose run --rm proxmox-platform discover scan --storage
docker-compose run --rm proxmox-platform discover scan --network
docker-compose run --rm proxmox-platform discover scan --guests
```

### Setup & Automation

```bash
# Run automated setup wizard
docker-compose run --rm -it proxmox-platform setup auto

# Preview changes (dry-run)
docker-compose run --rm proxmox-platform setup auto --dry-run

# Interactive wizard
docker-compose run --rm -it proxmox-platform setup wizard

# Validate deployment
docker-compose run --rm proxmox-platform setup validate
```

### Documentation Generation

```bash
# Generate all documentation
docker-compose run --rm proxmox-platform docs generate

# Generate specific docs
docker-compose run --rm proxmox-platform docs readme
docker-compose run --rm proxmox-platform docs preview
```

### Interactive Mode

```bash
# Interactive assistant (for exploration)
docker-compose run --rm -it proxmox-platform assistant

# Bash shell
docker-compose run --rm -it proxmox-platform shell

# Python REPL
docker-compose run --rm -it proxmox-platform python
```

## 📋 Environment Variables

### Required

| Variable | Example | Description |
|----------|---------|-------------|
| `PROXMOX_HOST` | `192.168.1.185` | Proxmox server IP or hostname |
| `PROXMOX_USER` | `root@pam` | Proxmox user (format: user@realm) |
| `PROXMOX_TOKEN_NAME` OR `PROXMOX_PASSWORD` | `automation` or password | Authentication method |

### Optional

| Variable | Default | Description |
|----------|---------|-------------|
| `PROXMOX_PORT` | `8006` | Proxmox API port |
| `PROXMOX_TOKEN_VALUE` | - | API token UUID (if using token auth) |
| `PROXMOX_VERIFY_SSL` | `true` | Verify SSL certificates |
| `PROXMOX_TIMEOUT` | `30` | API timeout (seconds) |
| `PROXMOX_SSH_HOST` | Same as `PROXMOX_HOST` | SSH host for direct access |
| `PROXMOX_SSH_PORT` | `22` | SSH port |
| `PROXMOX_SSH_USER` | `root` | SSH user |
| `PXMGR_LOG_LEVEL` | `INFO` | Logging level |
| `CONFIG_DIR` | `/app/config` | Configuration directory (in container) |
| `LOG_DIR` | `/app/logs` | Logs directory (in container) |

## 🔧 Configuration Methods

### Method 1: .env File (Recommended)

```bash
# .env file in same directory as docker-compose.yml
PROXMOX_HOST=192.168.1.185
PROXMOX_USER=root@pam
PROXMOX_TOKEN_NAME=automation
PROXMOX_TOKEN_VALUE=a2376549-e648-4f47-96cb-2b2933614a50
PROXMOX_VERIFY_SSL=false
```

### Method 2: Command-line Environment Variables

```bash
docker-compose run \
  -e PROXMOX_HOST=192.168.1.185 \
  -e PROXMOX_USER=root@pam \
  -e PROXMOX_TOKEN_NAME=automation \
  -e PROXMOX_TOKEN_VALUE=a2376549-e648-4f47-96cb-2b2933614a50 \
  proxmox-platform selftest
```

### Method 3: Docker Run (Without Compose)

```bash
docker run --rm \
  -e PROXMOX_HOST=192.168.1.185 \
  -e PROXMOX_USER=root@pam \
  -e PROXMOX_TOKEN_NAME=automation \
  -e PROXMOX_TOKEN_VALUE=a2376549-e648-4f47-96cb-2b2933614a50 \
  proxmox-platform:latest selftest
```

## 📁 Directory Structure

```
proxmox-docker/
├── Dockerfile              # Container build definition
├── docker-compose.yml      # Service orchestration
├── docker-entrypoint.sh    # Startup script
├── .dockerignore           # Build exclusions
├── .env                    # Configuration (create from .env.example)
├── .env.example            # Configuration template
├── config/                 # Persistent configuration (mounted volume)
├── logs/                   # Logs directory (mounted volume)
└── README.md               # This file
```

## 🔒 Security Notes

### Best Practices

1. **Secure .env file:**
   ```bash
   chmod 600 .env
   git add .env.example .gitignore  # Don't commit .env!
   ```

2. **Use API tokens** (not passwords):
   - More secure than storing passwords
   - Can be revoked individually
   - Limited scope/permissions

3. **Verify SSL in production:**
   ```
   PROXMOX_VERIFY_SSL=true
   ```

4. **Run with least privileges:**
   - Container runs as non-root user (pxmgr)
   - No new privileges allowed
   - Read-only SSH keys mount

5. **Rotate credentials regularly:**
   ```bash
   # Generate new token in Proxmox UI
   # Update .env file
   # Restart container
   ```

### Credential Storage Alternatives

For production, consider:
- **Docker Secrets** (Swarm mode)
- **Docker BuildKit** (build-time secrets)
- **Kubernetes Secrets** (K8s deployments)
- **HashiCorp Vault** (enterprise)
- **GitHub Secrets** (CI/CD)
- **Bitwarden** (password manager)

## 🐳 Docker Advanced Usage

### Build Custom Image

```bash
# Build with custom tag
docker build -t my-proxmox-platform:1.0 .

# Build for specific platform
docker buildx build --platform linux/amd64,linux/arm64 -t my-proxmox-platform:latest .
```

### Run Detached Service

```bash
# Start container in background
docker-compose up -d

# View logs
docker-compose logs -f proxmox-platform

# Stop container
docker-compose down
```

### Mount Additional Volumes

Edit `docker-compose.yml`:
```yaml
volumes:
  - ./config:/app/config
  - ./logs:/app/logs
  - ~/.ssh:/home/pxmgr/.ssh:ro
  - /path/to/scripts:/app/scripts:ro  # Add custom scripts
  - /path/to/data:/app/data           # Add data directory
```

### Resource Limits

Edit `docker-compose.yml`:
```yaml
deploy:
  resources:
    limits:
      cpus: '2'      # Max 2 CPUs
      memory: 2G     # Max 2GB RAM
    reservations:
      cpus: '0.5'    # Reserved 0.5 CPU
      memory: 512M   # Reserved 512MB
```

### Network Configuration

```bash
# Connect to external network
docker network connect my-network proxmox-pxmgr

# Use host network (Linux only)
# Add to docker-compose.yml:
# network_mode: "host"
```

## 🚨 Troubleshooting

### Connection Refused

```bash
# Check Proxmox is accessible
docker-compose run --rm proxmox-platform curl -k https://192.168.1.185:8006

# Verify firewall allows port 8006
telnet 192.168.1.185 8006
```

### SSL Certificate Errors

```bash
# For self-signed certificates, set:
# In .env:
PROXMOX_VERIFY_SSL=false

# Or run with flag:
docker-compose run --rm proxmox-platform pxmgr --help
```

### Authentication Failed

```bash
# Verify credentials in .env
cat .env | grep PROXMOX

# Check token exists in Proxmox UI
# Datacenter > Permissions > API Tokens

# Verify token has PVEAdmin or equivalent permissions
```

### Permission Denied on Volumes

```bash
# Fix volume permissions
sudo chown -R $(id -u):$(id -g) config logs

# Or run with specific user mapping
docker-compose run --user $(id -u):$(id -g) proxmox-platform ls /app/config
```

### Container Won't Start

```bash
# Check logs
docker-compose logs proxmox-platform

# Debug entry script
docker-compose run --rm proxmox-platform bash -x /usr/local/bin/docker-entrypoint.sh

# Test image manually
docker run -it --entrypoint /bin/bash proxmox-platform:latest
```

## 📊 Resource Usage

### Image Size

- Builder stage: ~800MB (removed from final image)
- Final image: ~500MB (multi-stage optimized)
- With config/logs: ~520MB

### Memory Usage

- Idle: ~100-150MB
- During operations: ~200-300MB
- With all features: ~500MB

### Disk Usage

```bash
# Check image size
docker images proxmox-platform

# Check container usage
docker system df

# Clean up unused images
docker image prune -a
```

## 🔄 Updating the Container

### Update From Repository

```bash
# Pull latest changes
git pull origin main

# Rebuild image
docker-compose build --no-cache

# Restart container
docker-compose down
docker-compose up -d
```

### Update Dependencies

```bash
# Rebuild with latest dependencies
docker-compose build --no-cache --build-arg BUILDKIT_INLINE_CACHE=1

# Test connection
docker-compose run --rm proxmox-platform test
```

## 📚 Additional Resources

- **Repository**: https://github.com/bryansrevision/proxmox-personal-data-platform
- **Proxmox Documentation**: https://pve.proxmox.com/wiki/Main_Page
- **Docker Documentation**: https://docs.docker.com/
- **GitHub Issue Tracker**: https://github.com/bryansrevision/proxmox-personal-data-platform/issues

## 🤝 Support

For issues or questions:

1. Check troubleshooting section above
2. Review logs: `docker-compose logs proxmox-platform`
3. Test connection: `docker-compose run --rm proxmox-platform test`
4. Open GitHub issue with:
   - Error message
   - Docker version
   - Platform (Windows/Mac/Linux)
   - Configuration (sanitized .env)

## 📄 License

MIT License - See repository for details

---

**Made with ❤️ for Proxmox homelab enthusiasts**
