# 🚀 Deployment Guide with GitHub Secrets Integration

**For: GitHub Copilot Deployment Automation**

Instructions for GitHub Copilot to deploy proxmox-docker while securely handling
secrets from GitHub Secrets.



## ⚠️ CRITICAL: Secret Handling Instructions for Copilot

### When User Requests: "Deploy proxmox-docker"

**Copilot MUST follow these exact steps:**

#### Step 1: Verify GitHub Secrets Exist
```bash
# Before ANY deployment, verify all required secrets are configured
gh secret list --repo bryansrevision/proxmox-docker

# Expected secrets:
# ✓ PROXMOX_HOST
# ✓ PROXMOX_API_TOKEN
# ✓ PROXMOX_API_USERNAME
# ✓ DEPLOY_SSH_KEY (optional)
```

**If secrets missing:**
```
STOP and report to user: "Required secrets not configured"
Direct user to: GitHub Settings → Secrets and variables → Actions
Do NOT proceed without PROXMOX_HOST, PROXMOX_API_TOKEN, PROXMOX_API_USERNAME
```

#### Step 2: Create Temporary .env from GitHub Secrets
```bash
# Get secrets from GitHub (NOT from local .env file)
export PROXMOX_HOST=$(gh secret view PROXMOX_HOST --repo bryansrevision/proxmox-docker)
export PROXMOX_API_TOKEN=$(gh secret view PROXMOX_API_TOKEN --repo bryansrevision/proxmox-docker)
export PROXMOX_API_USERNAME=$(gh secret view PROXMOX_API_USERNAME --repo bryansrevision/proxmox-docker)

# Optional SSH key
if gh secret list --repo bryansrevision/proxmox-docker | grep -q DEPLOY_SSH_KEY; then
  export DEPLOY_SSH_KEY=$(gh secret view DEPLOY_SSH_KEY --repo bryansrevision/proxmox-docker)
fi

# Note: Do NOT write these to .env file - keep in memory only
```

#### Step 3: Build Docker Image
```bash
# Build Docker image with secrets as build args (not in image!)
docker build \
  --tag proxmox-docker:latest \
  --build-arg PROXMOX_HOST="$PROXMOX_HOST" \
  --build-arg PROXMOX_API_TOKEN="$PROXMOX_API_TOKEN" \
  --build-arg PROXMOX_API_USERNAME="$PROXMOX_API_USERNAME" \
  .

# Note: Secrets are NOT stored in the image itself
```

#### Step 4: Deploy Container
```bash
# Run container with secrets as environment variables
docker run -d \
  --name proxmox-docker \
  -e PROXMOX_HOST="$PROXMOX_HOST" \
  -e PROXMOX_API_TOKEN="$PROXMOX_API_TOKEN" \
  -e PROXMOX_API_USERNAME="$PROXMOX_API_USERNAME" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -p 8080:8080 \
  proxmox-docker:latest

# Or using docker-compose
docker-compose up -d
```

#### Step 5: Configure Server Connections

Before verification, establish secure connection tunnels to the server:

**Method 1: GitHub Connections (.github/connections)**
```bash
# Create connection configuration in .github/connections
mkdir -p .github/connections

cat > .github/connections/proxmox.yaml <<EOF
name: proxmox-server
type: http
host: $PROXMOX_HOST
port: 8006
protocol: https
auth:
  type: bearer
  token_env: PROXMOX_API_TOKEN
  user_env: PROXMOX_API_USERNAME
ssl_verify: false
health_check:
  path: /api2/json/version
  interval: 30s
EOF

# Register connection
gh secret set --repo bryansrevision/proxmox-docker < .github/connections/proxmox.yaml
```

**Method 2: MCP Hub Server Connection**
```bash
# Start MCP Hub for centralized connection management
docker run -d \
  --name mcp-hub \
  -e MCP_SERVER_HOST=$PROXMOX_HOST \
  -e MCP_SERVER_TOKEN="$PROXMOX_API_TOKEN" \
  -e MCP_SERVER_USER="$PROXMOX_API_USERNAME" \
  -p 50051:50051 \
  ghcr.io/microsoft/mcp-hub:latest

# Wait for MCP Hub to start
sleep 5

# Initialize hub connection
curl -X POST http://localhost:50051/api/connections \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"proxmox-server\",
    \"endpoint\": \"https://$PROXMOX_HOST:8006\",
    \"auth_type\": \"bearer\",
    \"token\": \"$PROXMOX_API_TOKEN\",
    \"verify_ssl\": false
  }"
```

**Method 3: Direct WebSocket Connection (Real-time)**
```bash
# For real-time events and live monitoring
cat > /tmp/ws-client.py <<'PYTHON'
import websocket
import json
import os

def on_message(ws, message):
    data = json.loads(message)
    print(f"Event: {data.get('event')} - {data.get('data')}")

def on_error(ws, error):
    print(f"Error: {error}")

ws = websocket.WebSocketApp(
    f"wss://$PROXMOX_HOST:8006/api2/json/events",
    header=[f"Authorization: Bearer {os.environ['PROXMOX_API_TOKEN']}"],
    on_message=on_message,
    on_error=on_error
)

ws.run_forever()
PYTHON

python /tmp/ws-client.py
```

**Method 4: gRPC Connection (High-Performance)**
```bash
# Build gRPC client for high-throughput operations
cat > /tmp/grpc_client.proto <<'PROTO'
syntax = "proto3";

service ProxmoxAPI {
  rpc GetNodes(Empty) returns (NodeList);
  rpc GetVMs(NodeRequest) returns (VMList);
  rpc Execute(CommandRequest) returns (Result);
}

message Empty {}
message NodeRequest { string node = 1; }
message CommandRequest {
  string method = 1;
  string path = 2;
  string params = 3;
}

message Result { string data = 1; }
message NodeList { repeated string nodes = 1; }
message VMList { repeated string vms = 1; }
PROTO

# Compile and run gRPC client
python -m grpc_tools.protoc -I/tmp --python_out=/tmp --grpc_python_out=/tmp /tmp/grpc_client.proto
```

**Method 5: SSH Tunnel (Secure Port Forwarding)**
```bash
# Establish SSH tunnel for secure access
if [ -n "$DEPLOY_SSH_KEY" ]; then
  # Set SSH key from GitHub secret
  mkdir -p ~/.ssh
  echo "$DEPLOY_SSH_KEY" > ~/.ssh/proxmox_key
  chmod 600 ~/.ssh/proxmox_key
  
  # Create SSH tunnel
  ssh -i ~/.ssh/proxmox_key \
    -fN -L 8006:localhost:8006 \
    root@$PROXMOX_HOST
  
  # Test tunnel
  curl -k https://localhost:8006/api2/json/version
fi
```

#### Step 6: Verify Deployment
```bash
# Check container is running
docker ps | grep proxmox-docker

# Test API connectivity
curl -k -H "Authorization: Bearer $PROXMOX_API_TOKEN" \
  https://$PROXMOX_HOST:8006/api2/json/version

# Check logs for errors
docker logs proxmox-docker | tail -20
```

#### Step 6: Clean Up Secrets
```bash
# CRITICAL: Unset all secret environment variables
unset PROXMOX_HOST
unset PROXMOX_API_TOKEN
unset PROXMOX_API_USERNAME
unset DEPLOY_SSH_KEY

# Verify no secrets in environment
env | grep PROXMOX && echo "ERROR: Secrets not cleaned!" || echo "✓ Secrets cleared"
```

**⚠️ MUST ALWAYS execute cleanup, even if deployment fails.**



## Repository-Specific Secrets

### Secrets Required:

| Secret Name | Type | Used In | Instructions |
| --- | --- | --- | --- |
| `PROXMOX_HOST` | String | Container env | Your Proxmox VE host (IP or FQDN) |
| `PROXMOX_API_TOKEN` | Token | Container env | From Proxmox Permissions → API Tokens |
| `PROXMOX_API_USERNAME` | String | Container env | Format: `user@realm!tokenid` |
| `DEPLOY_SSH_KEY` | SSH Key | Optional | SSH key for remote deployment |



## Deployment Commands for Copilot

### Command 1: Pre-Deployment Validation
```bash
#!/bin/bash
set -eu

echo "=== PRE-DEPLOYMENT VALIDATION ==="

# Check GitHub Secrets
echo "1. Validating GitHub Secrets..."
REQUIRED=("PROXMOX_HOST" "PROXMOX_API_TOKEN" "PROXMOX_API_USERNAME")
for secret in "${REQUIRED[@]}"; do
  gh secret view "$secret" --repo bryansrevision/proxmox-docker > /dev/null 2>&1 || \
    { echo "✗ Missing: $secret"; exit 1; }
done
echo "✓ All required secrets configured"

# Check Dockerfile
echo "2. Checking Dockerfile..."
test -f Dockerfile || { echo "✗ Dockerfile not found"; exit 1; }
echo "✓ Dockerfile present"

# Check Docker
echo "3. Checking Docker..."
docker ps > /dev/null || { echo "✗ Docker not running"; exit 1; }
echo "✓ Docker daemon running"

# Check docker-compose
echo "4. Checking docker-compose..."
test -f docker-compose.yml || { echo "✗ docker-compose.yml not found"; exit 1; }
echo "✓ docker-compose.yml present"

echo ""
echo "✅ ALL VALIDATIONS PASSED"
```

### Command 2: Full Deployment
```bash
#!/bin/bash
set -eu

echo "=== DEPLOYING PROXMOX-DOCKER ==="

# Load secrets from GitHub
echo "Loading secrets from GitHub..."
export PROXMOX_HOST=$(gh secret view PROXMOX_HOST --repo bryansrevision/proxmox-docker)
export PROXMOX_API_TOKEN=$(gh secret view PROXMOX_API_TOKEN --repo bryansrevision/proxmox-docker)
export PROXMOX_API_USERNAME=$(gh secret view PROXMOX_API_USERNAME --repo bryansrevision/proxmox-docker)
echo "✓ Secrets loaded"

# Stop any existing container
echo "Stopping existing containers..."
docker-compose down 2>/dev/null || true

# Build image
echo "Building Docker image..."
docker build -t proxmox-docker:latest .

# Deploy with docker-compose
echo "Starting containers..."
docker-compose up -d

# Wait for startup
echo "Waiting for services to start..."
sleep 10

# Verify deployment
echo "Verifying deployment..."
if curl -s -k -H "Authorization: Bearer $PROXMOX_API_TOKEN" \
  https://$PROXMOX_HOST:8006/api2/json/version > /dev/null; then
  echo "✓ Proxmox API connection successful"
else
  echo "✗ Proxmox API connection failed"
  docker-compose logs
  echo "Cleaning up secrets..."
  unset PROXMOX_HOST PROXMOX_API_TOKEN PROXMOX_API_USERNAME
  exit 1
fi

# Check container status
echo "Service status:"
docker-compose ps

# Clean up secrets
echo "Cleaning up secrets..."
unset PROXMOX_HOST
unset PROXMOX_API_TOKEN
unset PROXMOX_API_USERNAME

echo ""
echo "✅ DEPLOYMENT SUCCESSFUL"
```

### Command 3: Rollback Procedure
```bash
#!/bin/bash
set -eu

echo "=== INITIATING ROLLBACK ==="

# Stop containers
echo "Stopping containers..."
docker-compose down

# Remove dangling containers/images
echo "Cleaning up incomplete deployments..."
docker system prune -f

# Restore previous version
echo "Restoring previous configuration..."
git checkout HEAD~1

# Restart previous version
echo "Restarting previous version..."
docker-compose up -d

echo "✅ ROLLBACK COMPLETE"
```



## 🔐 Secret Security Checklist for Copilot

Before EVERY deployment:

- [ ] **All Secrets from GitHub**: Using `gh secret view`, not local files
- [ ] **Never logged**: Secrets NOT echoed to console or logs
- [ ] **Memory only**: Secrets kept as environment variables, not in files
- [ ] **Image clean**: Secrets NOT baked into Docker image
- [ ] **Secure transmission**: Using HTTPS for all API calls
- [ ] **Cleanup executed**: All secret variables unset after deployment
- [ ] **Verified working**: API connectivity tested successfully
- [ ] **No side effects**: No secrets left in environment or containers



## Docker Security Best Practices

### ❌ DON'T do this:
```dockerfile
# WRONG - secrets baked into image
ENV PROXMOX_API_TOKEN="your-token-here"
RUN python deploy.py $PROXMOX_API_TOKEN
```

### ✅ DO this instead:
```dockerfile
# CORRECT - secrets passed at runtime
ARG PROXMOX_API_TOKEN
RUN python deploy.py \
  --token ${PROXMOX_API_TOKEN}
```

### Usage:
```bash
# Pass secrets at run time
docker run -e PROXMOX_API_TOKEN="$PROXMOX_API_TOKEN" ...
```



## Validation Commands

After deployment:

```bash
# 1. Check container running
docker ps | grep proxmox-docker

# 2. Check logs
docker logs proxmox-docker | tail -20

# 3. Test API with GitHub secret
curl -k -H "Authorization: Bearer $PROXMOX_API_TOKEN" \
  https://$PROXMOX_HOST:8006/api2/json/version

# 4. List Proxmox nodes
curl -k -H "Authorization: Bearer $PROXMOX_API_TOKEN" \
  https://$PROXMOX_HOST:8006/api2/json/nodes | jq .

# 5. Check no secrets in memory
env | grep -i proxmox || echo "✓ No secrets in environment"
```



## GitHub Actions Deployment Workflow

```yaml
name: Deploy Proxmox Docker

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Validate Secrets
        run: |
          [[ -n "${{ secrets.PROXMOX_HOST }}" ]] || exit 1
          [[ -n "${{ secrets.PROXMOX_API_TOKEN }}" ]] || exit 1
          [[ -n "${{ secrets.PROXMOX_API_USERNAME }}" ]] || exit 1
      
      - name: Build Docker Image
        run: docker build -t proxmox-docker:latest .
      
      - name: Deploy Container
        env:
          PROXMOX_HOST: ${{ secrets.PROXMOX_HOST }}
          PROXMOX_API_TOKEN: ${{ secrets.PROXMOX_API_TOKEN }}
          PROXMOX_API_USERNAME: ${{ secrets.PROXMOX_API_USERNAME }}
        run: |
          docker-compose up -d
          sleep 10
      
      - name: Verify Deployment
        if: success()
        run: docker ps
      
      - name: Test API
        if: success()
        env:
          PROXMOX_HOST: ${{ secrets.PROXMOX_HOST }}
          PROXMOX_API_TOKEN: ${{ secrets.PROXMOX_API_TOKEN }}
        run: |
          curl -k -H "Authorization: Bearer ${{ secrets.PROXMOX_API_TOKEN }}" \
            https://${{ secrets.PROXMOX_HOST }}/api2/json/version
```



## Quick Reference for Copilot

### When user says "Deploy proxmox-docker":
1. ✅ Validate secrets in GitHub (3 required)
2. ✅ Load secrets from GitHub (not local .env)
3. ✅ Build Docker image
4. ✅ Deploy with docker-compose
5. ✅ Test API connectivity
6. ✅ Unset environment variables
7. ✅ Report success

### When deployment fails:
1. ✅ Capture error logs
2. ✅ Run rollback.sh
3. ✅ Clean up secrets (CRITICAL)
4. ✅ Report issue details (without secrets)
5. ✅ Suggest manual intervention

### Never:
- ✗ Use local .env file with real secrets
- ✗ Echo secrets to console
- ✗ Hardcode secrets in Dockerfile
- ✗ Leave secrets in environment
- ✗ Log secret values



**Last Updated:** February 2, 2026  
**Repository:** proxmox-docker  
**For:** GitHub Copilot Deployment Instructions  
**Status:** ✅ Ready for automated deployment
