#!/bin/bash

# Check if container is running
if ! docker ps --format '{{.Names}}' | grep -q "^web-app$"; then
  echo "FAILURE: Container 'web-app' is not running."
  exit 1
fi

# Check if the heartbeat file exists in the mounted directory
if [ -f /opt/app-data/heartbeat ]; then
  echo "SUCCESS: Container can write to /opt/app-data!"
  exit 0
else
  echo "FAILURE: Container cannot write to /opt/app-data. Check permissions."
  exit 1
fi
