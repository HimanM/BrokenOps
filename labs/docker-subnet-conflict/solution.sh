#!/bin/bash

# Disconnect the container from the broken network
docker network disconnect broken_net app_container

# Remove the broken network
docker network rm broken_net

# Recreate the network with a safe private subnet (e.g., 172.30.0.0/24)
docker network create --subnet=172.30.0.0/24 safe_net

# Connect the container to the new safe network
docker network connect safe_net app_container
