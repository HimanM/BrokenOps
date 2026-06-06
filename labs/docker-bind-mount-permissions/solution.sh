#!/bin/bash

# Fix host directory ownership to match container user (UID 1000)
chown 1000:1000 /opt/app-data
chmod 755 /opt/app-data

# The container retries every 5 seconds, so it should eventually succeed.
# But for faster verification in CI, we can restart it.
docker restart web-app
