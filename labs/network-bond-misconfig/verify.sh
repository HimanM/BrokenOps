#!/bin/bash

# Check if bond0 exists and is in active-backup mode
if ! cat /proc/net/bonding/bond0 2>/dev/null | grep -q "Bonding Mode: fault-tolerance (active-backup)"; then
    echo "FAILURE: bond0 is not in active-backup mode."
    exit 1
fi

# Check if both slaves are up and enslaved
SLAVE_COUNT=$(cat /proc/net/bonding/bond0 2>/dev/null | grep -c "Slave Interface")
if [ "$SLAVE_COUNT" -ne 2 ]; then
    echo "FAILURE: bond0 should have 2 slaves, but has $SLAVE_COUNT."
    exit 1
fi

echo "SUCCESS: Network bond is correctly configured in active-backup mode."
exit 0
