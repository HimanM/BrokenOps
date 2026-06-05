# BrokenOps

BrokenOps is a self-hosted DevOps training platform that runs locally on your machine.
It spins up intentionally broken Linux environments using Libvirt and QEMU, allowing you to troubleshoot real system issues, verify your fixes, and reset the environments easily.

## Features
- **Local-first**: Runs entirely on your machine.
- **Reproducible & Resettable**: Broken states are generated via `cloud-init` on top of an immutable base image.
- **Category-driven Learning**: Labs are organized by categories like Linux, Docker, Kubernetes, etc.

## Setup

### Prerequisites
- Linux host with KVM/Libvirt installed and configured.
- Python 3.12+
- Node.js & npm

### Installation
1. Clone this repository.
2. Initialize the backend:
   ```bash
   cd backend
   python3 -m venv venv
   source venv/bin/activate
   pip install fastapi uvicorn pydantic pyyaml libvirt-python
   ```
3. Initialize the frontend:
   ```bash
   cd frontend
   npm install
   ```
4. Download the base image:
   ```bash
   mkdir -p data/images
   cd data/images
   wget https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img -O ubuntu-24.04-base.qcow2
   ```

### Running the application
- Start the backend: `cd backend && uvicorn main:app --reload`
- Start the frontend: `cd frontend && npm run dev`

Navigate to the frontend URL to view the Lab Browser and launch your first lab!
