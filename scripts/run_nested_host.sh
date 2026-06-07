#!/bin/bash
set -e

DISTRO=$1
IMAGE_PATH=$2

if [ -z "$DISTRO" ] || [ -z "$IMAGE_PATH" ]; then
    echo "Usage: $0 <distro> <image_path>"
    exit 1
fi

echo "===================================================="
echo "Booting Nested Host VM: $DISTRO"
echo "===================================================="

DISTRO_SLUG=$(echo "$DISTRO" | tr '[:upper:]' '[:lower:]' | tr -d ' ')
ABS_IMAGE_PATH=$(readlink -f "$IMAGE_PATH")
ABS_OVERLAY_IMAGE=$(readlink -f "data/images/nested-${DISTRO_SLUG}-overlay.qcow2" 2>/dev/null || echo "$PWD/data/images/nested-${DISTRO_SLUG}-overlay.qcow2")
SSH_OPTS=(-p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i keys/id_ed25519)

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

echo "instance-id: nested-host-${DISTRO_SLUG}" > meta-data

genisoimage -output cidata.iso -volid cidata -joliet -rock user-data meta-data
rm user-data meta-data

mkdir -p data/images
qemu-img create -f qcow2 -F qcow2 -b "$ABS_IMAGE_PATH" "$ABS_OVERLAY_IMAGE" 20G

echo "Starting QEMU process..."
sudo qemu-system-x86_64 \
  -enable-kvm \
  -cpu host \
  -smp 2 \
  -m 4096 \
  -drive file="$ABS_OVERLAY_IMAGE",if=virtio,format=qcow2 \
  -drive file=cidata.iso,media=cdrom \
  -net nic,model=virtio \
  -net user,hostfwd=tcp::2222-:22 \
  -display none \
  -daemonize > qemu.log 2>&1 || { cat qemu.log; exit 1; }

echo "Waiting for SSH on nested $DISTRO VM..."
SSH_SUCCESS=0
for i in {1..60}; do
    if ssh "${SSH_OPTS[@]}" -o BatchMode=yes -o ConnectTimeout=5 root@localhost "true" >/dev/null 2>&1; then
        echo "SSH is ready."
        SSH_SUCCESS=1
        break
    fi
    sleep 2
done

if [ "$SSH_SUCCESS" -ne 1 ]; then
    echo "SSH failed to become ready. QEMU output log:"
    cat qemu.log || true
    exit 1
fi

ssh "${SSH_OPTS[@]}" root@localhost "cloud-init status --wait || true"

echo "Packaging workspace and copying to nested VM..."
tar -czf workspace.tar.gz --exclude=.git --exclude=data/images --exclude=workspace.tar.gz --exclude=qemu.log --exclude=cidata.iso . || [ $? -eq 1 ]

SCP_SUCCESS=0
for i in {1..5}; do
    if scp -P 2222 -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i keys/id_ed25519 workspace.tar.gz root@localhost:/tmp/; then
        SCP_SUCCESS=1
        break
    fi
    echo "Workspace copy failed, retrying ($i/5)..."
    sleep 5
done

if [ "$SCP_SUCCESS" -ne 1 ]; then
    echo "Failed to copy workspace to nested $DISTRO VM."
    exit 1
fi

ssh "${SSH_OPTS[@]}" root@localhost "mkdir -p /workspace && tar -xzf /tmp/workspace.tar.gz -C /workspace && rm /tmp/workspace.tar.gz"
rm workspace.tar.gz

echo "Nested $DISTRO VM is fully prepared."
