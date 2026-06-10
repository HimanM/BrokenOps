#!/bin/bash

# Check if we have a route to 10.50.0.1
# 'ip route get' will show which route is used to reach an address
if ip route get 10.50.0.1 2>/dev/null | grep -q "192.168.123.1"; then
    # Also verify it's in Netplan
    if grep -r "10.50.0.0/24" /etc/netplan/ && grep -r "192.168.123.1" /etc/netplan/; then
        echo "SUCCESS: Static route is configured and persistent."
        exit 0
    else
        echo "FAILURE: Route exists in live state but is not found in Netplan configurations."
        exit 1
    fi
else
    echo "FAILURE: Static route to 10.50.0.0/24 (via 192.168.123.1) is missing."
    exit 1
fi
