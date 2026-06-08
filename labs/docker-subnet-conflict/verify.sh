#!/bin/bash

# Get the host's IP address
HOST_IP=$(ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)

# Execute a ping to the host IP from inside the container
if docker exec app_container ping -c 1 -W 2 $HOST_IP > /dev/null 2>&1; then
    echo "SUCCESS: Container successfully reached host IP ($HOST_IP)!"
    exit 0
else
    echo "FAILURE: Container failed to reach host IP ($HOST_IP). Subnet conflict still exists."
    exit 1
fi
