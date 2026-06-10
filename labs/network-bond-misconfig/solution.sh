#!/bin/bash

# 1. Update the live configuration
# We must take the bond down to change the mode
ip link set bond0 down
ip link set bond0 type bond mode active-backup
ip link set bond0 up

# 2. Update the persistent Netplan configuration
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
        mode: active-backup
        mii-monitor-interval: 100
        primary: eth1
EOF

# Apply persistent config
netplan apply
