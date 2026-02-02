# Proxmox Platform Docker - Quick Reference Guide

## 🚀 One-Liner Setup

```bash
cd proxmox-docker && cp .env.example .env && nano .env && docker-compose build && docker-compose run --rm proxmox-platform test
```

## 📋 Essential Commands

| Task | Command |
|------|---------|
| **Test connection** | `docker-compose run --rm proxmox-platform test` |
| **List nodes** | `docker-compose run --rm proxmox-platform node list` |
| **List VMs** | `docker-compose run --rm proxmox-platform vm list` |
| **Interactive shell** | `docker-compose run --rm -it proxmox-platform shell` |
| **View help** | `docker-compose run --rm proxmox-platform --help` |
| **Start container** | `docker-compose up -d` |
| **View logs** | `docker-compose logs -f` |
| **Stop container** | `docker-compose down` |

## 🔑 Required .env Variables

```env
PROXMOX_HOST=192.168.1.185
PROXMOX_USER=root@pam
PROXMOX_TOKEN_NAME=automation
PROXMOX_TOKEN_VALUE=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

## 🐳 Docker Commands (Without Compose)

```bash
# Build image
docker build -t proxmox-platform:latest .

# Run command
docker run --rm \
  --env-file .env \
  proxmox-platform:latest node list

# Interactive shell
docker run --rm -it \
  --env-file .env \
  --entrypoint /bin/bash \
  proxmox-platform:latest
```

## 📁 Volume Mounts

- `/app/config` - Configuration files
- `/app/logs` - Application logs
- `/home/pxmgr/.ssh` - SSH keys (optional)

## 🔐 Security Checklist

- [ ] .env file has mode 600: `chmod 600 .env`
- [ ] Using API token (not password)
- [ ] .env not committed to git
- [ ] SSH key mounted read-only
- [ ] Container running as non-root
- [ ] SSL verification enabled for production

## 🛠️ Troubleshooting

**Connection failed?** → Check PROXMOX_HOST and firewall
**SSL error?** → Set `PROXMOX_VERIFY_SSL=false` for self-signed certs
**Permission denied?** → Run `sudo chown -R $(id -u):$(id -g) config logs`
**Won't start?** → Check logs: `docker-compose logs proxmox-platform`

## 📞 Getting Help

```bash
# Check logs
docker-compose logs proxmox-platform

# Test connection manually
docker-compose run --rm proxmox-platform pxmgr selftest --verbose

# List available commands
docker-compose run --rm proxmox-platform pxmgr --help
```

---

For complete documentation, see **README.md**
