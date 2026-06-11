#!/bin/bash

# Find the primary interface
PRIMARY_IF=$(ip route | grep default | awk '{print $5}' | head -n 1)
if [ -z "$PRIMARY_IF" ]; then PRIMARY_IF="eth0"; fi

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
          via: 192.168.123.1
EOF

# Apply the route live
# Use onlink in case the gateway is not directly reachable on the subnet
ip route add 10.50.0.0/24 via 192.168.123.1 dev $PRIMARY_IF onlink || true

# Apply persistent config
netplan apply
