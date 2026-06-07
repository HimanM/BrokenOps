#!/bin/bash

# Get the VM's own IP address
VM_IP=$(hostname -I | awk '{print $1}')

# Try to mount the local NFS export
mkdir -p /mnt/verify_nfs
if mount -t nfs -o timeo=20,retrans=1 ${VM_IP}:/srv/nfs/shared /mnt/verify_nfs > /dev/null 2>&1; then
    umount /mnt/verify_nfs
    echo "SUCCESS: NFS share is accessible!"
    exit 0
else
    echo "FAILURE: Cannot mount NFS share from ${VM_IP}. Access denied or server unreachable."
    exit 1
fi
