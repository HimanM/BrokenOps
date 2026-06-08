#!/bin/bash

# Execute a ping to 8.8.8.8 from inside the container
if docker exec app_container ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
    echo "SUCCESS: Container successfully reached 8.8.8.8!"
    exit 0
else
    echo "FAILURE: Container failed to reach 8.8.8.8. Subnet conflict still exists."
    exit 1
fi
