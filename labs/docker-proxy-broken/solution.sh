#!/bin/bash
set -euo pipefail

mkdir -p /etc/systemd/system/docker.service.d
cat <<'DROPIN' > /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=http://127.0.0.1:8888"
Environment="HTTPS_PROXY=http://127.0.0.1:8888"
Environment="NO_PROXY=localhost,127.0.0.1"
DROPIN

systemctl daemon-reload
systemctl restart docker

docker pull hello-world >/dev/null

echo "SUCCESS: Docker daemon proxy configured and image pull succeeded."
