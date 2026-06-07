#!/bin/bash

# Check if docker service is active
if ! systemctl is-active --quiet docker; then
    echo "FAILURE: Docker service is not running."
    exit 1
fi

# Check if docker socket is active
if ! systemctl is-active --quiet docker.socket; then
    echo "FAILURE: Docker socket is not running."
    exit 1
fi

# Try to run a docker command
if ! docker ps > /dev/null 2>&1; then
    echo "FAILURE: Cannot communicate with Docker daemon."
    journalctl -u docker -n 20 --no-pager
    exit 1
fi

echo "SUCCESS: Docker daemon is healthy and responding!"
exit 0
