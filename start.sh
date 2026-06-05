#!/bin/bash
set -e

# ==============================================================================
# BrokenOps - Interactive Setup & Launcher
# ==============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}      🚀 Welcome to BrokenOps Environment Setup     ${NC}"
echo -e "${BLUE}====================================================${NC}"
echo ""

# Helper to print steps
step() {
    echo -e "${YELLOW}>> $1${NC}"
}
success() {
    echo -e "${GREEN}✓ $1${NC}"
}
error_exit() {
    echo -e "${RED}✗ $1${NC}"
    exit 1
}

# 1. Check System Dependencies
step "Checking System Dependencies..."
CMDS="python3 npm node virsh qemu-img xorriso wget"
MISSING=""

for CMD in $CMDS; do
    if ! command -v $CMD >/dev/null 2>&1; then
        MISSING="$MISSING $CMD"
    fi
done

if [ -n "$MISSING" ]; then
    echo -e "${RED}Missing required commands:${NC}$MISSING"
    echo -e "${YELLOW}Please install the missing tools using your system's package manager (e.g., pacman, apt, dnf) before continuing.${NC}"
    read -p "Press Enter to try continuing anyway, or Ctrl+C to abort..."
else
    success "All system dependencies are met."
fi

# 2. Check Libvirt Group
if ! groups $USER | grep -q '\blibvirt\b'; then
    step "Adding user to libvirt group..."
    sudo usermod -aG libvirt $USER
    echo -e "${YELLOW}Notice: You have been added to the 'libvirt' group. You may need to log out and log back in for this to take effect completely if VM operations fail.${NC}"
fi

# 3. Download Base Image
step "Checking for Ubuntu 24.04 base image..."
mkdir -p data/images
if [ ! -f "data/images/ubuntu-24.04-base.qcow2" ]; then
    echo "Downloading Ubuntu 24.04 base image (this might take a few minutes)..."
    wget --progress=bar:force https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img -O data/images/ubuntu-24.04-base.qcow2
    success "Base image downloaded."
else
    success "Base image found."
fi

# 4. Setup Backend
step "Setting up backend environment..."
cd backend
if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv venv
fi

source venv/bin/activate
echo "Installing Python dependencies..."
pip install -q fastapi uvicorn pydantic pyyaml libvirt-python asyncssh websockets

if [ ! -f "keys/id_ed25519" ]; then
    echo "Generating SSH keys for VM access..."
    mkdir -p keys
    ssh-keygen -t ed25519 -f keys/id_ed25519 -N "" -q
    success "SSH keys generated."
fi
success "Backend setup complete."

# Start Backend
step "Starting FastAPI backend server..."
uvicorn main:app --host 0.0.0.0 --port 8080 > backend.log 2>&1 &
BACKEND_PID=$!
cd ..

# 5. Setup Frontend
step "Setting up frontend environment..."
cd frontend
if [ ! -d "node_modules" ]; then
    echo "Installing NPM dependencies..."
    npm install --silent
fi
success "Frontend setup complete."

# Start Frontend
step "Starting Vite frontend server..."
npm run dev &
FRONTEND_PID=$!
cd ..

echo ""
echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN}          ✨ BrokenOps is now running! ✨           ${NC}"
echo -e "${GREEN}====================================================${NC}"
echo -e "${BLUE}UI Access:${NC}    http://localhost:5173"
echo -e "${BLUE}Backend API:${NC}  http://localhost:8080"
echo -e "${YELLOW}Press Ctrl+C at any time to stop both servers.${NC}"
echo -e "${GREEN}====================================================${NC}"

# Trap Ctrl+C to kill background processes
trap "echo -e '\n${RED}[BrokenOps]${NC} Shutting down servers...'; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; exit 0" SIGINT SIGTERM

# Wait indefinitely until interrupted
wait
