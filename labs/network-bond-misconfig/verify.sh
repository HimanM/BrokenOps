#!/bin/bash

# Check if ens4 exists and has the correct IP
if ip addr show ens4 2>/dev/null | grep -q "10.10.10.10"; then
    # Also verify it's in Netplan and eth1 is gone
    if grep -q "ens4:" /etc/netplan/60-internal-nic.yaml && ! grep -q "eth1:" /etc/netplan/60-internal-nic.yaml; then
        echo "SUCCESS: Secondary interface is correctly configured and up."
        exit 0
    else
        echo "FAILURE: Netplan configuration still refers to eth1 or doesn't have ens4."
        exit 1
    fi
else
    echo "FAILURE: ens4 does not have the expected IP address 10.10.10.10."
    exit 1
fi
