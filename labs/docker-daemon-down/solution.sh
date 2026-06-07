#!/bin/bash

# Remove the trailing comma in daemon.json
# A simple way is to overwrite with valid JSON
cat <<EOF > /etc/docker/daemon.json
{
  "debug": true,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m"
  }
}
EOF

# 2. Restart docker
systemctl stop docker || true
systemctl stop docker.socket || true
systemctl reset-failed docker
systemctl start docker.socket || true
systemctl start docker
