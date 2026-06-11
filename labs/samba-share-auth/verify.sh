#!/bin/bash

# Check if devuser can access the engineering share
# We use smbclient to test authentication
if smbclient //localhost/engineering -U devuser%BrokenOps123 -c "ls" > /dev/null 2>&1; then
    echo "SUCCESS: devuser can access the engineering share."
    exit 0
else
    echo "FAILURE: devuser still cannot access the engineering share."
    exit 1
fi
