#!/bin/bash

# Update Netplan configuration to use ens4 instead of eth1
sed -i 's/eth1:/ens4:/' /etc/netplan/60-internal-nic.yaml

# Apply the new configuration
netplan apply
