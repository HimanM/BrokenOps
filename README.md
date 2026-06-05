# BrokenOps

**BrokenOps** is an interactive, open-source DevOps and Sysadmin training platform. It automatically spins up intentionally broken virtual machines and challenges you to troubleshoot, fix, and verify real-world system failures right from your browser.

> ⚠️ **IMPORTANT: Linux Required**  
> BrokenOps relies heavily on native **KVM (Kernel-based Virtual Machine)** and **Libvirt** to provision and manage lightweight virtual machines in milliseconds. Because of this architectural dependency, **this platform ONLY works on native Linux machines.**  
> *(WSL2 and nested Linux VMs are not officially supported due to complex bridging and routing limitations.)*

---

## 🌟 Features

- **Instant Environments**: Uses blazing-fast `qcow2` overlay disks to boot fully isolated Ubuntu environments in seconds.
- **In-Browser Terminal**: A fully integrated, multiplexed `xterm.js` pseudo-terminal lets you SSH directly into the broken instances without leaving the UI.
- **Automated Verification**: Click **Verify** to run dynamic grading scripts against your VM to see if your fix actually worked.
- **Dynamic Port Exposing**: If a lab requires you to fix a web service, the UI will automatically expose a clickable button to test your fix in the browser once the VM boots.
- **Gamified Tracking**: Automatically saves your progress locally. Earn a "COMPLETED" badge for every scenario you conquer!

## 🚀 Getting Started

BrokenOps includes a fully interactive, cross-distro setup wizard that will automatically check your dependencies, install missing packages, set up your Python environments, and start the application.

1. Clone the repository:
   ```bash
   git clone https://github.com/HimanM/BrokenOps.git
   cd BrokenOps
   ```

2. Run the deployment script to build and start the Docker containers:
   ```bash
   ./deploy.sh
   ```
   > ⚠️ **IMPORTANT: Docker Desktop Users**  
   > If you have Docker Desktop installed on your Linux machine, it will intercept the deployment and run the backend inside its hidden VM. This breaks the required Libvirt socket mapping. To force a deployment to your native Linux Docker daemon, run:
   > ```bash
   > DOCKER_HOST=unix:///var/run/docker.sock ./deploy.sh
   > ```

3. The script will automatically download the necessary Ubuntu base images and start both the **FastAPI Backend** and the **React Frontend**.
4. Access the UI at: `http://localhost:80`

## 🛠️ Architecture Stack

- **Frontend**: React 18, Vite, TailwindCSS v4, `xterm.js` for the terminal interface.
- **Backend**: FastAPI (Python), `asyncssh` for real-time terminal websocket multiplexing, `libvirt-python` for hypervisor orchestration.
- **Virtualization**: Libvirt, KVM, QEMU, `cloud-init` for zero-touch provisioning.

## 📚 Creating Custom Labs

Want to build your own intentionally broken scenario? It's incredibly easy! 

Read our comprehensive [Lab Creator Guide (LAB_FORMAT.md)](./LAB_FORMAT.md) to learn how to structure your `lab.yaml`, `cloud-init.yaml`, and write custom `verify.sh` grading scripts.

---
*Built with ❤️ for engineers who love breaking things.*
