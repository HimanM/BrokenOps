#!/bin/bash

# Find the primary interface and its gateway
PRIMARY_IF=$(ip route | grep default | awk '{print $5}' | head -n 1)
if [ -z "$PRIMARY_IF" ]; then PRIMARY_IF="eth0"; fi
GATEWAY=$(ip route | grep default | awk '{print $3}' | head -n 1)
if [ -z "$GATEWAY" ]; then GATEWAY="192.168.123.1"; fi

# Update Netplan with the new static route
cat <<EOF > /etc/netplan/60-static-route.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    $PRIMARY_IF:
      dhcp4: true
      routes:
        - to: 10.50.0.0/24
          via: $GATEWAY
EOF

# Apply the route live (use -d to ignore if already exists)
ip route add 10.50.0.0/24 via $GATEWAY dev $PRIMARY_IF || true

# Apply persistent config
netplan apply
