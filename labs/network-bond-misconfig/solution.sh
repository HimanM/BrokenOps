#!/bin/bash

# Update Netplan configuration to use balance-alb mode
cat <<EOF > /etc/netplan/60-bond.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth1:
      optional: true
    eth2:
      optional: true
  bonds:
    bond0:
      interfaces: [eth1, eth2]
      parameters:
        mode: balance-alb
        mii-monitor-interval: 100
EOF

# Apply the new configuration
netplan apply
