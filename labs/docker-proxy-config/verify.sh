#!/bin/bash

# Check if Docker can pull alpine (using the local proxy)
# In our lab, the fix is to set the correct proxy port (3128)
if docker pull alpine:latest 2>&1 | grep -q "Image is up to date"; then
    echo "SUCCESS: Docker can pull images."
    exit 0
else
    # Try again with --quiet to check actual success if above fails
    if docker pull -q alpine:latest > /dev/null 2>&1; then
        echo "SUCCESS: Docker can pull images."
        exit 0
    fi
    echo "FAILURE: Docker pull still failing."
    exit 1
fi
