#!/bin/bash
if netplan apply > /dev/null 2>&1; then
    echo "SUCCESS: Netplan configuration is valid and applied!"
    exit 0
else
    echo "FAILURE: Netplan configuration has errors."
    exit 1
fi
