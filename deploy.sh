#!/bin/bash

set -e

RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
WHITE='\033[1;37m'

banner() {
    printf "\n${CYAN}${BOLD}%s${RESET}\n" "===================================================="
    printf "${CYAN}${BOLD}%-52s${RESET}\n" "$1"
    printf "${CYAN}${BOLD}%s${RESET}\n\n" "===================================================="
}

section() {
    printf "\n${BLUE}${BOLD}%s${RESET}\n" "────────────────────────────────────────────────────"
    printf "${WHITE}${BOLD}%s${RESET}\n" "$1"
    printf "${BLUE}${BOLD}%s${RESET}\n" "────────────────────────────────────────────────────"
}

status() {
    printf "${GREEN}${BOLD}•${RESET} %s\n" "$1"
}

warn() {
    printf "${YELLOW}${BOLD}!${RESET} %s\n" "$1"
}

error() {
    printf "${RED}${BOLD}x${RESET} %s\n" "$1"
}

prompt() {
    printf "\n${WHITE}${BOLD}%s${RESET}\n" "$1"
    printf "${CYAN}${BOLD}>${RESET} %s" "$2"
}

SUDO=""
if [ "$(id -u)" -ne 0 ] && command -v sudo &> /dev/null; then
    SUDO="sudo"
fi

banner "BrokenOps Production Deploy"
printf "${DIM}Native Linux deployment for the lab platform.${RESET}\n"

section "Host Setup"
if ! command -v ansible-playbook &> /dev/null; then
    warn "Ansible not found. Installing Ansible..."
    if command -v apt-get &> /dev/null; then
        $SUDO apt-get update && $SUDO apt-get install -y ansible
    elif command -v dnf &> /dev/null; then
        $SUDO dnf install -y ansible
    elif command -v pacman &> /dev/null; then
        $SUDO pacman -S --noconfirm ansible
    elif command -v apk &> /dev/null; then
        $SUDO apk add ansible
    else
        error "Unsupported package manager. Please install Ansible manually."
        exit 1
    fi
else
    status "Ansible is already available."
fi

status "Running Ansible playbook for host setup..."
ANSIBLE_BIN=$(command -v ansible-playbook)
$SUDO "$ANSIBLE_BIN" ansible/setup.yml

if command -v lsmod &> /dev/null; then
    if ! lsmod | grep -iq kvm; then
        warn "KVM module not detected in lsmod. If you are in a VM, ensure nested virtualization is enabled."
    fi
fi

section "Container Runtime"
DOCKER_COMPOSE="docker compose"
if ! docker compose version &> /dev/null; then
    if command -v docker-compose &> /dev/null; then
        DOCKER_COMPOSE="docker-compose"
    else
        error "Neither 'docker compose' nor 'docker-compose' found."
        exit 1
    fi
fi
status "Using Docker Compose command: $DOCKER_COMPOSE"

section "User Input"
if [ "$ASSUME_YES" = "1" ]; then
    FRONTEND_PORT=${FRONTEND_PORT:-80}
    status "Auto-confirm mode enabled. Using frontend port $FRONTEND_PORT."
else
    prompt "Which port should the BrokenOps UI run on?" "[default: 80] "
    read FRONTEND_PORT
    FRONTEND_PORT=${FRONTEND_PORT:-80}
fi

section "Host Identity"
HOST_UID=$(id -u)
HOST_GID=$(id -g)
LIBVIRT_GID=$(getent group libvirt | cut -d: -f3)
KVM_GID=$(getent group kvm | cut -d: -f3)

if [ -z "$LIBVIRT_GID" ]; then
    error "Could not determine libvirt group ID on host. Is libvirtd installed?"
    exit 1
fi

status "Detected Host UID: $HOST_UID, GID: $HOST_GID, libvirt GID: $LIBVIRT_GID, KVM GID: ${KVM_GID:-none}"

section "Environment File"
cat <<EOF > .env
PUID=$HOST_UID
PGID=$HOST_GID
LIBVIRT_GID=$LIBVIRT_GID
KVM_GID=${KVM_GID:-0}
FRONTEND_PORT=$FRONTEND_PORT
HOST_PROJECT_ROOT=$PWD
EOF

status "Generated .env file for Docker Compose."

section "Assets"
if [ ! -f "keys/id_ed25519" ]; then
    warn "Generating SSH keys for VM access..."
    mkdir -p keys
    ssh-keygen -t ed25519 -f keys/id_ed25519 -N ""
else
    status "SSH key already exists."
fi

mkdir -p data/images
if [ ! -f "data/images/ubuntu-24.04-base.qcow2" ]; then
    warn "Downloading Ubuntu 24.04 base image..."
    curl -f -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" -o data/images/ubuntu-24.04-base.qcow2 https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
else
    status "Ubuntu 24.04 base image already present."
fi

section "Startup"
if [ "$DRY_RUN" != "1" ]; then
    status "Building and starting Docker containers..."
    $DOCKER_COMPOSE up -d --build
else
    warn "Dry-run mode active. Skipping Docker Compose startup."
fi

section "Complete"
printf "${GREEN}${BOLD}%s${RESET}\n" "BrokenOps successfully deployed."
printf "${BLUE}${BOLD}UI Access:${RESET} http://localhost:%s\n" "$FRONTEND_PORT"
printf "${DIM}Backend API remains inside the Docker network.${RESET}\n"
printf "${DIM}Built by HimanM${RESET}\n"
