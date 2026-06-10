#!/bin/bash

# Check if eth0 MTU is at least 1500
MTU_VALUE=$(cat /sys/class/net/eth0/mtu)

if [ "$MTU_VALUE" -lt 1500 ]; then
    echo "FAILURE: eth0 MTU is still too low ($MTU_VALUE)."
    exit 1
fi

# Try to download the large file locally to verify it doesn't hang
if curl -s http://localhost/largefile.bin -o /dev/null; then
    echo "SUCCESS: MTU is correct and large packets are passing."
    exit 0
else
    echo "FAILURE: Large file download failed even with correct MTU."
    exit 1
fi
