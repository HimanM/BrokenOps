#!/bin/bash
set -euo pipefail
cat <<'EOF' > /opt/brokenops/.env
BROKENOPS_IMAGE=nginx:alpine
BROKENOPS_PORT=8080
EOF
cd /opt/brokenops
docker compose config >/dev/null
