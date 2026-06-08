#!/bin/bash

# Run the application script
if /opt/app/bin/run.sh > /dev/null 2>&1; then
    echo "SUCCESS: Application running successfully. Links are fixed."
    exit 0
else
    echo "FAILURE: Application failed to start. Links are still broken."
    exit 1
fi
