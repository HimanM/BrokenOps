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

# 1. Check for required host dependencies
MISSING_DEPS=()

if ! command -v docker &> /dev/null; then
    MISSING_DEPS+=("docker")
fi

if ! command -v qemu-img &> /dev/null; then
    MISSING_DEPS+=("qemu-utils")
fi

if command -v lsmod &> /dev/null; then
    if ! lsmod | grep -iq kvm; then
        echo -e "${RED}Error: KVM is not enabled on this host! Nested virtualization or hardware acceleration is required.${NC}"
        exit 1
    fi
else
    if [ ! -e /dev/kvm ]; then
        echo -e "${RED}Error: KVM is not enabled on this host! Nested virtualization or hardware acceleration is required.${NC}"
        exit 1
    fi
fi

if ! getent group libvirt > /dev/null; then
    MISSING_DEPS+=("libvirt-daemon-system")
fi

if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
    echo -e "${YELLOW}Missing required host dependencies: ${MISSING_DEPS[*]}${NC}"
    if [ "$ASSUME_YES" = "1" ]; then
        REPLY="y"
    else
        read -p "Would you like to install them now? (requires sudo) [Y/n] " -n 1 -r
        echo
    fi
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        if command -v apt-get &> /dev/null; then
            $SUDO apt-get update
            $SUDO apt-get install -y "${MISSING_DEPS[@]}"
        elif command -v dnf &> /dev/null; then
            DEPS_TO_INSTALL=()
            for dep in "${MISSING_DEPS[@]}"; do
                if [ "$dep" = "qemu-utils" ]; then
                    DEPS_TO_INSTALL+=("qemu-img")
                elif [ "$dep" = "libvirt-daemon-system" ]; then
                    DEPS_TO_INSTALL+=("libvirt")
                else
                    DEPS_TO_INSTALL+=("$dep")
                fi
            done
            $SUDO dnf install -y "${DEPS_TO_INSTALL[@]}"
        elif command -v pacman &> /dev/null; then
            DEPS_TO_INSTALL=()
            for dep in "${MISSING_DEPS[@]}"; do
                if [ "$dep" = "qemu-utils" ]; then
                    DEPS_TO_INSTALL+=("qemu-base")
                elif [ "$dep" = "libvirt-daemon-system" ]; then
                    DEPS_TO_INSTALL+=("libvirt")
                else
                    DEPS_TO_INSTALL+=("$dep")
                fi
            done
            $SUDO pacman -Sy --noconfirm "${DEPS_TO_INSTALL[@]}"
        elif command -v apk &> /dev/null; then
            DEPS_TO_INSTALL=()
            for dep in "${MISSING_DEPS[@]}"; do
                if [ "$dep" = "qemu-utils" ]; then
                    DEPS_TO_INSTALL+=("qemu-img")
                elif [ "$dep" = "libvirt-daemon-system" ]; then
                    DEPS_TO_INSTALL+=("libvirt")
                else
                    DEPS_TO_INSTALL+=("$dep")
                fi
            done
            $SUDO apk add "${DEPS_TO_INSTALL[@]}"
        else
            echo -e "${RED}Unsupported package manager. Please install dependencies manually: ${MISSING_DEPS[*]}${NC}"
            exit 1
        fi
        # Ensure docker and libvirtd services are enabled and started on systemd/openrc hosts
        if command -v systemctl &> /dev/null; then
            $SUDO systemctl enable --now docker || true
            $SUDO systemctl enable --now libvirtd || true
        elif command -v rc-service &> /dev/null; then
            $SUDO rc-update add docker default || true
            $SUDO rc-service docker start || true
            $SUDO rc-update add libvirtd default || true
            $SUDO rc-service libvirtd start || true
        fi

        # Ensure user is in libvirt and kvm groups
        if [ "$(id -u)" -ne 0 ]; then
            if ! groups "$USER" | grep -q "\blibvirt\b"; then
                echo -e "${YELLOW}Adding $USER to libvirt group...${NC}"
                $SUDO usermod -aG libvirt "$USER" || true
            fi
            if ! groups "$USER" | grep -q "\bkvm\b"; then
                echo -e "${YELLOW}Adding $USER to kvm group...${NC}"
                $SUDO usermod -aG kvm "$USER" || true
            fi
        fi

        # Make libvirt socket accessible
        if [ -S /var/run/libvirt/libvirt-sock ]; then
            $SUDO chmod 666 /var/run/libvirt/libvirt-sock
        fi
    else
        echo -e "${RED}Cannot proceed without dependencies. Exiting.${NC}"
        exit 1
    fi
fi

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
    docker compose up -d --build
else
    echo -e "${YELLOW}Dry-run mode active. Skipping Docker Compose startup.${NC}"
fi

echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN}✨ BrokenOps successfully deployed via Docker! ✨   ${NC}"
echo -e "${GREEN}====================================================${NC}"
echo -e "${BLUE}UI Access:${NC}    http://localhost:$FRONTEND_PORT"
echo -e "${YELLOW}Note: The backend API is safely hidden inside the Docker network.${NC}"
echo -e "${GREEN}======================By HimanM=====================${NC}"
