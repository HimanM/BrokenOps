#!/bin/bash

# Check if 'apt update' succeeds
if apt-get update; then
    echo "SUCCESS: Package manager repositories are working correctly."
    exit 0
else
    echo "FAILURE: Package manager repository update failed."
    exit 1
fi
