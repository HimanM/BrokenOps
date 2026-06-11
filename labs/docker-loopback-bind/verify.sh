#!/bin/bash
set -euo pipefail
cd /opt/brokenops/docker-loopback-bind
docker build -t brokenops-loopback-bind . >/tmp/brokenops-loopback-build.log 2>&1
docker rm -f brokenops-loopback-bind >/dev/null 2>&1 || true
docker run -d --name brokenops-loopback-bind -p 8080:8080 brokenops-loopback-bind >/dev/null
trap 'docker rm -f brokenops-loopback-bind >/dev/null 2>&1 || true' EXIT
sleep 3
if curl -fsS http://127.0.0.1:8080/ >/tmp/brokenops-loopback-response.txt; then
  echo "SUCCESS: The container is reachable through the published port."
  exit 0
fi
echo "FAILURE: The published port still is not reachable."
docker logs brokenops-loopback-bind --tail 20 || true
exit 1
