#!/bin/bash
set -euo pipefail
cd /opt/brokenops/compose-service-dns-breaks-after-rename
docker compose down -v >/dev/null 2>&1 || true
docker compose up -d --build >/tmp/brokenops-compose-build.log 2>&1
trap 'docker compose down -v >/dev/null 2>&1 || true' EXIT
sleep 5
if curl -fsS http://127.0.0.1:8080/ | grep -q 'BrokenOps backend is alive'; then
  echo "SUCCESS: Compose resolves the backend service name and the proxy serves content."
  exit 0
fi
echo "FAILURE: The proxy still cannot reach the backend service."
docker compose logs --tail 20 proxy || true
exit 1
