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

# Restart docker
systemctl restart docker
