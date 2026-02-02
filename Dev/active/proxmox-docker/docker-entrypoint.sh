#!/bin/bash
# Docker entrypoint script for Proxmox Personal Data Platform

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ENV_FILE="${ENV_FILE:-.env}"
CONFIG_DIR="${CONFIG_DIR:-/app/config}"
LOG_DIR="${LOG_DIR:-/app/logs}"

# Ensure directories exist
mkdir -p "$CONFIG_DIR" "$LOG_DIR"

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if .env file exists
if [ ! -f "$ENV_FILE" ]; then
    print_warn ".env file not found at $ENV_FILE"
    print_info "Creating .env file from defaults..."
    
    # Copy from /app/.env.example if it exists
    if [ -f "/app/.env.example" ]; then
        cp /app/.env.example "$ENV_FILE"
        print_success "Created $ENV_FILE from .env.example"
        print_warn "Please edit $ENV_FILE with your Proxmox credentials"
    else
        print_error ".env.example not found. Cannot create .env file."
        print_info "Please mount or create a .env file with your Proxmox configuration"
        exit 1
    fi
fi

# Source the .env file to load variables
if [ -f "$ENV_FILE" ]; then
    print_info "Loading configuration from $ENV_FILE..."
    set -a
    source "$ENV_FILE"
    set +a
    print_success "Configuration loaded"
else
    print_error "Configuration file not found: $ENV_FILE"
    exit 1
fi

# Validate required environment variables
if [ -z "$PROXMOX_HOST" ]; then
    print_error "PROXMOX_HOST not set in .env file"
    exit 1
fi

if [ -z "$PROXMOX_USER" ]; then
    print_error "PROXMOX_USER not set in .env file"
    exit 1
fi

if [ -z "$PROXMOX_TOKEN_NAME" ] && [ -z "$PROXMOX_PASSWORD" ]; then
    print_error "Either PROXMOX_TOKEN_NAME or PROXMOX_PASSWORD must be set in .env"
    exit 1
fi

# Log execution info
print_info "Starting Proxmox Personal Data Platform (pxmgr)"
print_info "Target: $PROXMOX_HOST"
print_info "User: $PROXMOX_USER"
print_info "Config Directory: $CONFIG_DIR"
print_info "Log Directory: $LOG_DIR"

# Handle different commands
case "${1:-help}" in
    # CLI commands
    selftest|test|status|health)
        print_info "Running: pxmgr $@"
        exec pxmgr "$@"
        ;;
    
    # Node operations
    node|vm|api|assistant|wizard|setup|discover|track|docs)
        print_info "Running: pxmgr $@"
        exec pxmgr "$@"
        ;;
    
    # Custom shell
    shell|bash|sh)
        print_info "Starting interactive shell..."
        exec /bin/bash
        ;;
    
    # Python REPL
    python|py)
        print_info "Starting Python REPL..."
        exec python
        ;;
    
    # Custom script execution
    script)
        shift
        if [ -z "$1" ]; then
            print_error "No script specified"
            print_info "Usage: docker run <image> script <script_path> [args...]"
            exit 1
        fi
        script_path="$1"
        shift
        if [ -f "$script_path" ]; then
            print_info "Running script: $script_path"
            exec python "$script_path" "$@"
        else
            print_error "Script not found: $script_path"
            exit 1
        fi
        ;;
    
    # Health check command
    healthcheck)
        print_info "Running health check..."
        pxmgr selftest --verbose 2>/dev/null || exit 1
        exit 0
        ;;
    
    # Default help
    help|--help|-h)
        cat << 'EOF'
Usage: docker run [OPTIONS] proxmox-platform [COMMAND]

Commands:
  selftest              Test Proxmox connection and configuration
  test                  Alias for selftest
  status                Show Proxmox cluster status
  health                Run health checks
  node                  Manage Proxmox nodes
  vm                    Manage virtual machines
  api                   Raw API operations
  assistant             Start interactive assistant
  wizard                Start setup wizard
  setup                 Automated setup commands
  discover              Infrastructure discovery
  track                 Change tracking and versioning
  docs                  Documentation generation
  
  shell                 Start interactive bash shell
  bash                  Alias for shell
  python                Start Python REPL
  script <path> [args]  Execute custom Python script
  
  help                  Show this help message

Examples:
  # Test connection
  docker run -e PROXMOX_HOST=192.168.1.100 proxmox-platform selftest
  
  # List nodes
  docker run -e PROXMOX_HOST=192.168.1.100 proxmox-platform node list
  
  # Interactive shell
  docker run -it proxmox-platform shell
  
  # With .env file
  docker run --env-file .env proxmox-platform vm list
  
  # With volume mount for config
  docker run -v $(pwd)/.env:/.env proxmox-platform selftest

Environment Variables:
  PROXMOX_HOST         Proxmox server IP/hostname (required)
  PROXMOX_PORT         Proxmox API port (default: 8006)
  PROXMOX_USER         Proxmox user (format: user@realm) (required)
  PROXMOX_TOKEN_NAME   API token name (recommended for auth)
  PROXMOX_TOKEN_VALUE  API token value
  PROXMOX_PASSWORD     User password (alternative auth)
  PROXMOX_VERIFY_SSL   Verify SSL certs (default: true)
  PROXMOX_TIMEOUT      API timeout in seconds (default: 30)
  PROXMOX_SSH_HOST     SSH host (default: same as PROXMOX_HOST)
  PROXMOX_SSH_PORT     SSH port (default: 22)
  PROXMOX_SSH_USER     SSH user (default: root)

Configuration:
  Mount .env file:      -v /path/to/.env:/.env
  Mount config dir:     -v /path/to/config:/app/config
  Mount SSH keys:       -v ~/.ssh:/home/pxmgr/.ssh
  
  Or use environment variables:
  --env-file .env
  -e PROXMOX_HOST=192.168.1.100
  -e PROXMOX_USER=root@pam
  -e PROXMOX_TOKEN_NAME=automation
  -e PROXMOX_TOKEN_VALUE=xxxx-xxxx-xxxx-xxxx

Documentation:
  https://github.com/bryansrevision/proxmox-personal-data-platform

For more information, run:
  docker run proxmox-platform pxmgr --help
EOF
        exit 0
        ;;
    
    # Pass through to pxmgr
    *)
        print_info "Running: pxmgr $@"
        exec pxmgr "$@"
        ;;
esac
