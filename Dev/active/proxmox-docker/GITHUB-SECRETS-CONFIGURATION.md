# GitHub Secrets Configuration

Sensitive credentials for this repository are managed through GitHub Secrets,
not committed to code.

## Secrets Configured

| Secret Name | Used In | Description |
| --- | --- | --- |
| `PROXMOX_HOST` | Workflows | Proxmox VE host address (IP or FQDN) |
| `PROXMOX_API_TOKEN` | Workflows | Proxmox API token for automation |
| `PROXMOX_API_USERNAME` | Workflows | Proxmox API user (format: `user@realm!tokenid`) |
| `DEPLOY_SSH_KEY` | Workflows | SSH private key for deployment access |

## How to Add Secrets

### GitHub Web UI:

1. Go to repository Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Enter name and value
4. Click "Add secret"

### Using GitHub CLI:

```bash
gh secret set PROXMOX_HOST --body "192.168.1.100"
gh secret set PROXMOX_API_TOKEN --body "your-token-here"
gh secret set PROXMOX_API_USERNAME --body "user@realm!tokenid"
gh secret set DEPLOY_SSH_KEY < ~/.ssh/id_rsa
```

## Local Development

Use `.env` file for local development (not committed):

```dotenv
PROXMOX_HOST=192.168.1.100
PROXMOX_API_TOKEN=your-token-uuid
PROXMOX_API_USERNAME=automation@pam!automation
```

Reference: See [START-HERE.md](./START-HERE.md) for setup instructions

## Using in Workflows

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy

on: [push]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to Proxmox
        env:
          PROXMOX_HOST: ${{ secrets.PROXMOX_HOST }}
          PROXMOX_API_TOKEN: ${{ secrets.PROXMOX_API_TOKEN }}
          PROXMOX_API_USERNAME: ${{ secrets.PROXMOX_API_USERNAME }}
        run: |
          python scripts/deploy.py
```

## Security

- ✅ `.env` files excluded via `.gitignore`
- ✅ Secrets referenced via `${{ secrets.NAME }}`
- ✅ SSH keys never committed
- ✅ All credentials stored in GitHub Secrets

**Reference:** `GITHUB-SECRETS-CONFIGURATION.md` (master guide)



**Status:** ⏳ Secrets need to be added to GitHub  
**Setup Time:** ~5 minutes  
**Next:** Add secrets to GitHub, then verify in workflows
