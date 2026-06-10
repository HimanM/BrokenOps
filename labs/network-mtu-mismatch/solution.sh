#!/bin/bash

# Update Netplan configuration to use standard MTU 1500
cat <<EOF > /etc/netplan/60-mtu.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: true
      mtu: 1500
EOF

# Apply the change live
ip link set dev eth0 mtu 1500

# Apply persistent config
netplan apply
