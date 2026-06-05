#!/bin/bash
set -e

echo -e "\e[1;34m[BrokenOps]\e[0m Starting up..."

# 1. Check and download Base Image
echo -e "\e[1;34m[BrokenOps]\e[0m Checking for Ubuntu 24.04 base image..."
mkdir -p data/images
if [ ! -f "data/images/ubuntu-24.04-base.qcow2" ]; then
    echo "Downloading Ubuntu base image (this might take a while)..."
    wget https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img -O data/images/ubuntu-24.04-base.qcow2
else
    echo "Base image found."
fi

# 2. Setup Backend
echo -e "\e[1;34m[BrokenOps]\e[0m Setting up backend..."
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
fi

# Start Backend in background
echo -e "\e[1;34m[BrokenOps]\e[0m Starting FastAPI backend on port 8080..."
uvicorn main:app --host 0.0.0.0 --port 8080 > backend.log 2>&1 &
BACKEND_PID=$!
cd ..

# 3. Setup Frontend
echo -e "\e[1;34m[BrokenOps]\e[0m Setting up frontend..."
cd frontend
if [ ! -d "node_modules" ]; then
    echo "Installing NPM dependencies..."
    npm install
fi

# Start Frontend
echo -e "\e[1;34m[BrokenOps]\e[0m Starting Vite frontend server..."
npm run dev &
FRONTEND_PID=$!
cd ..

echo -e "\n\e[1;32m====================================================\e[0m"
echo -e "\e[1;32m  BrokenOps is now running!\e[0m"
echo -e "\e[1;32m  Access the UI at: http://localhost:5173\e[0m"
echo -e "\e[1;32m  Press Ctrl+C to stop both servers.\e[0m"
echo -e "\e[1;32m====================================================\e[0m\n"

# Trap Ctrl+C to kill background processes
trap "echo -e '\n\e[1;31m[BrokenOps]\e[0m Shutting down servers...'; kill $BACKEND_PID $FRONTEND_PID; exit 0" SIGINT SIGTERM

# Wait indefinitely until interrupted
wait
