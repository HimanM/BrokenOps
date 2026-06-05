#!/bin/bash
if [ -f /var/log/massive_rogue.log ]; then
    SIZE=$(stat -c%s /var/log/massive_rogue.log)
    if [ "$SIZE" -gt 0 ]; then
        echo "FAILURE: The rogue file still exists and takes up space."
        exit 1
    fi
fi

USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$USAGE" -ge 90 ]; then
    echo "FAILURE: Disk usage is still $USAGE%."
    exit 1
fi

echo "SUCCESS: Disk space recovered!"
exit 0
