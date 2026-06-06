#!/bin/bash
set -e

# Target parameters
DISTRO=$1
IMAGE_PATH=$2

if [ -z "$DISTRO" ] || [ -z "$IMAGE_PATH" ]; then
    echo "Usage: $0 <distro> <image_path>"
    exit 1
fi

echo "===================================================="
echo "🚀 Booting Nested Host VM: $DISTRO"
echo "===================================================="

# 1. Create temporary cloud-init configuration
mkdir -p keys
if [ ! -f "keys/id_ed25519" ]; then
    ssh-keygen -t ed25519 -f keys/id_ed25519 -N ""
fi

PUB_KEY=$(cat keys/id_ed25519.pub)

cat <<EOF > user-data
#cloud-config
disable_root: false
ssh_authorized_keys:
  - $PUB_KEY
users:
  - name: root
    ssh_authorized_keys:
      - $PUB_KEY
runcmd:
  - sed -i 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/* || true
  - systemctl restart ssh || systemctl restart sshd || true
EOF

echo "instance-id: nested-host-$DISTRO" > meta-data

# 2. Build cloud-init ISO
genisoimage -output cidata.iso -volid cidata -joliet -rock user-data meta-data
rm user-data meta-data

# 3. Create overlay QCOW2 image
OVERLAY_IMAGE="data/images/nested-$DISTRO-overlay.qcow2"
qemu-img create -f qcow2 -F qcow2 -b "$IMAGE_PATH" "$OVERLAY_IMAGE" 20G

# 4. Launch QEMU with CPU host passthrough (Nested virtualization enabled)
sudo qemu-system-x86_64 \
  -enable-kvm \
  -cpu host \
  -smp 2 \
  -m 4096 \
  -drive file="$OVERLAY_IMAGE",if=virtio,format=qcow2 \
  -drive file=cidata.iso,media=cdrom \
  -net nic,model=virtio \
  -net user,hostfwd=tcp::2222-:22 \
  -nographic \
  -daemonize

# 5. Wait for SSH to be up
echo "⏳ Waiting for SSH (port 2222) on nested $DISTRO VM..."
for i in {1..30}; do
    if nc -z localhost 2222; then
        echo "✅ SSH is up!"
        break
    fi
    sleep 2
done

# Wait a few more seconds for cloud-init runcmd to complete SSH configuration
sleep 5

# 6. Copy workspace to the nested VM
echo "📦 Packaging workspace and copying to nested VM..."
tar -czf workspace.tar.gz --exclude=.git --exclude=data/images --exclude=workspace.tar.gz .
scp -P 2222 -o StrictHostKeyChecking=no -i keys/id_ed25519 workspace.tar.gz root@localhost:/tmp/
ssh -p 2222 -o StrictHostKeyChecking=no -i keys/id_ed25519 root@localhost "mkdir -p /workspace && tar -xzf /tmp/workspace.tar.gz -C /workspace && rm /tmp/workspace.tar.gz"
rm workspace.tar.gz

echo "✅ Nested $DISTRO VM is fully prepared!"
