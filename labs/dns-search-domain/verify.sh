#!/bin/bash

# Check if the short hostname 'api-server' can be resolved
# It should resolve to 10.0.0.50 if search domain is correct
if getent hosts api-server | grep -q "10.0.0.50"; then
    echo "SUCCESS: Short hostname 'api-server' resolves to 10.0.0.50"
    exit 0
else
    echo "FAILURE: Cannot resolve short hostname 'api-server'. Check search domains."
    exit 1
fi
