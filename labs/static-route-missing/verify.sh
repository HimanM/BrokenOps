#!/bin/bash

# Check if a route to 10.50.0.0/24 exists
if ip route show 10.50.0.0/24 | grep -q "10.50.0.0/24"; then
    # Also verify it's in Netplan
    if grep -r "10.50.0.0/24" /etc/netplan/; then
        echo "SUCCESS: Static route is configured and persistent."
        exit 0
    else
        echo "FAILURE: Route exists in live state but is not found in Netplan configurations."
        exit 1
    fi
else
    echo "FAILURE: Static route to 10.50.0.0/24 is missing."
    exit 1
fi
