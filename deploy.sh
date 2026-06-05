#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}      🚀 BrokenOps Production Deploy Script         ${NC}"
echo -e "${BLUE}====================================================${NC}"

# 1. Check for required host dependencies
MISSING_DEPS=()

if ! command -v docker &> /dev/null; then
    MISSING_DEPS+=("docker")
fi

if ! command -v qemu-img &> /dev/null; then
    MISSING_DEPS+=("qemu-utils")
fi

if ! lsmod | grep -iq kvm; then
    echo -e "${RED}Error: KVM is not enabled on this host! Nested virtualization or hardware acceleration is required.${NC}"
    exit 1
fi

if ! getent group libvirt > /dev/null; then
    MISSING_DEPS+=("libvirt-daemon-system")
fi

if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
    echo -e "${YELLOW}Missing required host dependencies: ${MISSING_DEPS[*]}${NC}"
    read -p "Would you like to install them now? (requires sudo) [Y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        sudo apt-get update
        sudo apt-get install -y "${MISSING_DEPS[@]}"
    else
        echo -e "${RED}Cannot proceed without dependencies. Exiting.${NC}"
        exit 1
    fi
fi

# 2. Get Port configuration
read -p "Which port should the BrokenOps UI run on? [default: 80]: " FRONTEND_PORT
FRONTEND_PORT=${FRONTEND_PORT:-80}

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

# 5. Build and Start via Docker Compose
echo -e "${BLUE}Building and starting Docker containers...${NC}"
docker compose up -d --build

echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN}✨ BrokenOps successfully deployed via Docker! ✨   ${NC}"
echo -e "${GREEN}====================================================${NC}"
echo -e "${BLUE}UI Access:${NC}    http://localhost:$FRONTEND_PORT"
echo -e "${YELLOW}Note: The backend API is safely hidden inside the Docker network.${NC}"
echo -e "${GREEN}====================================================${NC}"
