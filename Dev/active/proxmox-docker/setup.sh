#!/bin/bash
# Setup script for Proxmox Docker Platform
# Makes initial setup easier on Windows/Mac/Linux

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Proxmox Personal Data Platform - Docker Setup Script    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker not found. Please install Docker Desktop.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker found${NC}"

if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}✗ Docker Compose not found. Please install Docker Compose.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker Compose found${NC}"

echo ""

# Create .env file if doesn't exist
if [ ! -f .env ]; then
    echo -e "${YELLOW}Creating .env file from template...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✓ Created .env (please edit with your Proxmox details)${NC}"
    echo ""
    
    # Prompt to edit
    read -p "Do you want to edit .env now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v nano &> /dev/null; then
            nano .env
        elif command -v vim &> /dev/null; then
            vim .env
        else
            echo -e "${YELLOW}Please edit .env with your Proxmox credentials${NC}"
        fi
    fi
else
    echo -e "${GREEN}✓ .env file already exists${NC}"
fi

echo ""

# Create directories
echo -e "${YELLOW}Creating directories...${NC}"
mkdir -p config logs
echo -e "${GREEN}✓ Created config and logs directories${NC}"

echo ""

# Secure .env file
echo -e "${YELLOW}Setting file permissions...${NC}"
chmod 600 .env
chmod 755 config logs
echo -e "${GREEN}✓ File permissions set${NC}"

echo ""

# Build Docker image
echo -e "${YELLOW}Building Docker image...${NC}"
echo -e "${BLUE}(This may take a few minutes on first run)${NC}"
docker-compose build

echo ""
echo -e "${GREEN}✓ Docker image built successfully${NC}"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║             Setup Complete!                               ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo ""
echo "1. ${YELLOW}Edit .env${NC} with your Proxmox credentials:"
echo "   nano .env"
echo ""
echo "2. ${YELLOW}Test the connection:${NC}"
echo "   docker-compose run --rm proxmox-platform test"
echo ""
echo "3. ${YELLOW}Run your first command:${NC}"
echo "   docker-compose run --rm proxmox-platform node list"
echo ""
echo "4. ${YELLOW}For interactive shell:${NC}"
echo "   docker-compose run --rm -it proxmox-platform shell"
echo ""
echo -e "${BLUE}For more help:${NC}"
echo "  - Read README.md for detailed documentation"
echo "  - See QUICK-START.md for common commands"
echo "  - Run: docker-compose run --rm proxmox-platform --help"
echo ""
