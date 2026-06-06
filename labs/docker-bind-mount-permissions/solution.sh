#!/bin/bash

# Fix host directory ownership to match container user (UID 1000)
chown 1000:1000 /opt/app-data
chmod 755 /opt/app-data

# Wait for the container to write the heartbeat file (it retries every 5 seconds)
for i in {1..10}; do
  if [ -f /opt/app-data/heartbeat ]; then
    break
  fi
  sleep 1
done

