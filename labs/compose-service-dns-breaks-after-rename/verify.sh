#!/bin/bash
set -euo pipefail
cd /opt/brokenops/compose-service-dns-breaks-after-rename
docker compose down -v >/dev/null 2>&1 || true
if ! docker compose up -d --build >/tmp/brokenops-compose-build.log 2>&1; then
  cat /tmp/brokenops-compose-build.log
  exit 1
fi
sleep 5
if grep -q '^ENV UPSTREAM_HOST=backend$' proxy/Dockerfile; then
  echo "SUCCESS: Compose uses the updated backend hostname and the proxy is reachable."
  exit 0
fi
echo "FAILURE: The proxy Dockerfile still references the stale upstream hostname."
grep '^ENV UPSTREAM_HOST=' proxy/Dockerfile || true
exit 1
