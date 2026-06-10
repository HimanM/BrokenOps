#!/bin/bash

# Update Netplan with the new static route
# We assume the primary interface is eth0
cat <<EOF > /etc/netplan/60-static-route.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: true
      routes:
        - to: 10.50.0.0/24
          via: 192.168.123.1
EOF

# Apply the route live
ip route add 10.50.0.0/24 via 192.168.123.1 dev eth0

# Apply persistent config
netplan apply
