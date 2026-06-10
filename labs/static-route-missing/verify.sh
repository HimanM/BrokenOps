#!/bin/bash

# Check if a route to 10.50.0.0/24 exists via 192.168.123.1
if ip route show 10.50.0.0/24 | grep -q "via 192.168.123.1"; then
    # Also verify it's in Netplan
    if grep -q "10.50.0.0/24" /etc/netplan/*.yaml; then
        echo "SUCCESS: Static route is configured and persistent."
        exit 0
    else
        echo "FAILURE: Route exists in live state but is not persistent in Netplan."
        exit 1
    fi
else
    echo "FAILURE: Static route to 10.50.0.0/24 is missing."
    exit 1
fi
