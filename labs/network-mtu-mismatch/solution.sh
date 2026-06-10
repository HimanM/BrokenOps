#!/bin/bash

# Find primary interface
PRIMARY_IF=$(ip route | grep default | awk '{print $5}' | head -n 1)
if [ -z "$PRIMARY_IF" ]; then PRIMARY_IF="eth0"; fi

# Update Netplan configuration to use standard MTU 1500
cat <<EOF > /etc/netplan/60-mtu.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    $PRIMARY_IF:
      dhcp4: true
      mtu: 1500
EOF

# Apply the change live
ip link set dev "$PRIMARY_IF" mtu 1500

# Apply persistent config
netplan apply
