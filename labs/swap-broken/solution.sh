#!/bin/bash

# Ensure swapfile exists (if deleted during troubleshooting)
if [ ! -f /swapfile ]; then
  dd if=/dev/zero of=/swapfile bs=1M count=512
  chmod 600 /swapfile
  mkswap /swapfile
fi

# Activate the swap file immediately
swapon /swapfile || true

# Add persistent configuration to /etc/fstab if not present
if ! grep -q '/swapfile' /etc/fstab; then
  echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi
