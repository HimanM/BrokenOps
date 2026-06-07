#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

SUDO=""
if [ "$(id -u)" -ne 0 ] && command -v sudo &> /dev/null; then
    SUDO="sudo"
fi

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}      🚀 BrokenOps Production Deploy Script         ${NC}"
echo -e "${BLUE}====================================================${NC}"

# 1. Check for and install Ansible if missing
if ! command -v ansible-playbook &> /dev/null; then
    echo -e "${YELLOW}Ansible not found. Installing Ansible...${NC}"
    if command -v apt-get &> /dev/null; then
        $SUDO apt-get update && $SUDO apt-get install -y ansible
    elif command -v dnf &> /dev/null; then
        $SUDO dnf install -y ansible
    elif command -v pacman &> /dev/null; then
        $SUDO pacman -S --noconfirm ansible
    elif command -v apk &> /dev/null; then
        $SUDO apk add ansible
    else
        echo -e "${RED}Unsupported package manager. Please install Ansible manually.${NC}"
        exit 1
    fi
fi

# 2. Run Ansible playbook to setup host
echo -e "${BLUE}Running Ansible playbook for host setup...${NC}"
# Use absolute path if possible or ensure PATH is inherited
ANSIBLE_BIN=$(command -v ansible-playbook)
$SUDO "$ANSIBLE_BIN" ansible/setup.yml

# 3. Check for KVM (still good to have a quick check here)
if command -v lsmod &> /dev/null; then
    if ! lsmod | grep -iq kvm; then
        echo -e "${YELLOW}Warning: KVM module not detected in lsmod. If you are in a VM, ensure nested virtualization is enabled.${NC}"
    fi
fi

# 3.5 Detect Docker Compose command
DOCKER_COMPOSE="docker compose"
if ! docker compose version &> /dev/null; then
    if command -v docker-compose &> /dev/null; then
        DOCKER_COMPOSE="docker-compose"
    else
        echo -e "${RED}Error: Neither 'docker compose' nor 'docker-compose' found.${NC}"
        exit 1
    fi
fi
echo -e "${GREEN}Using Docker Compose command: $DOCKER_COMPOSE${NC}"

# 2. Get Port configuration
if [ "$ASSUME_YES" = "1" ]; then
    FRONTEND_PORT=${FRONTEND_PORT:-80}
else
    read -p "Which port should the BrokenOps UI run on? [default: 80]: " FRONTEND_PORT
    FRONTEND_PORT=${FRONTEND_PORT:-80}
fi

# 3. Get Host UID/GID for strict permissions
HOST_UID=$(id -u)
HOST_GID=$(id -g)
LIBVIRT_GID=$(getent group libvirt | cut -d: -f3)

if [ -z "$LIBVIRT_GID" ]; then
    echo -e "${RED}Could not determine libvirt group ID on host. Is libvirtd installed?${NC}"
    exit 1
fi

echo -e "${GREEN}Detected Host UID: $HOST_UID, GID: $HOST_GID, libvirt GID: $LIBVIRT_GID${NC}"

# 4. Generate .env file
cat <<EOF > .env
PUID=$HOST_UID
PGID=$HOST_GID
LIBVIRT_GID=$LIBVIRT_GID
FRONTEND_PORT=$FRONTEND_PORT
HOST_PROJECT_ROOT=$PWD
EOF

echo -e "${GREEN}Generated .env file for Docker Compose.${NC}"

# 5. Generate SSH keys if they don't exist
if [ ! -f "keys/id_ed25519" ]; then
    echo -e "${YELLOW}Generating SSH keys for VM access...${NC}"
    mkdir -p keys
    ssh-keygen -t ed25519 -f keys/id_ed25519 -N ""
fi

# 5.5 Download default base image if missing
mkdir -p data/images
if [ ! -f "data/images/ubuntu-24.04-base.qcow2" ]; then
    echo -e "${YELLOW}Downloading Ubuntu 24.04 base image...${NC}"
    curl -f -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" -o data/images/ubuntu-24.04-base.qcow2 https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
fi

# 6. Build and Start via Docker Compose
if [ "$DRY_RUN" != "1" ]; then
    echo -e "${BLUE}Building and starting Docker containers...${NC}"
    $DOCKER_COMPOSE up -d --build
else
    echo -e "${YELLOW}Dry-run mode active. Skipping Docker Compose startup.${NC}"
fi

echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN}✨ BrokenOps successfully deployed via Docker! ✨   ${NC}"
echo -e "${GREEN}====================================================${NC}"
echo -e "${BLUE}UI Access:${NC}    http://localhost:$FRONTEND_PORT"
echo -e "${YELLOW}Note: The backend API is safely hidden inside the Docker network.${NC}"
echo -e "${GREEN}======================By HimanM=====================${NC}"
