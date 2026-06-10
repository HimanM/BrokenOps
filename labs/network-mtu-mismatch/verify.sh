#!/bin/bash

# Find primary interface
PRIMARY_IF=$(ip route | grep default | awk '{print $5}' | head -n 1)
if [ -z "$PRIMARY_IF" ]; then PRIMARY_IF="eth0"; fi

# Check MTU using ip command
MTU_VALUE=$(ip link show "$PRIMARY_IF" | grep -oP 'mtu \K\d+')

if [ -z "$MTU_VALUE" ]; then
    echo "FAILURE: Could not determine MTU for interface $PRIMARY_IF."
    exit 1
fi

if [ "$MTU_VALUE" -lt 1500 ]; then
    echo "FAILURE: $PRIMARY_IF MTU is still too low ($MTU_VALUE)."
    exit 1
fi

# Try to download the large file locally to verify it doesn't hang
if curl -s --max-time 10 http://localhost/largefile.bin -o /dev/null; then
    echo "SUCCESS: MTU is correct and large packets are passing."
    exit 0
else
    echo "FAILURE: Large file download failed or timed out even with correct MTU."
    exit 1
fi
