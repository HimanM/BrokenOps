#!/bin/bash
# Remove the custom Netplan profile containing the invalid gateway override
rm -f /etc/netplan/99-custom.yaml

# Apply the default Netplan configuration
netplan apply
