#!/bin/bash

# Remove the container entirely to avoid network state issues
docker rm -f app_container || true

# Remove the broken network
docker network rm broken_net || true

# Recreate the network with a safe private subnet (e.g., 172.30.0.0/24)
docker network create --subnet=172.30.0.0/24 safe_net || true

# Restart the container on the new safe network
docker run -d --name app_container --network safe_net nginx
