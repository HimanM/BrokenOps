#!/bin/bash

# Update systemd-resolved to include the correct search domain
mkdir -p /etc/systemd/resolved.conf.d
cat <<EOF > /etc/systemd/resolved.conf.d/search.conf
[Resolve]
Domains=internal.brokenops.io
EOF

# Restart systemd-resolved
systemctl restart systemd-resolved
