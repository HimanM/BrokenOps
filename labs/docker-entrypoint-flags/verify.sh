#!/bin/bash
set -euo pipefail
cd /opt/brokenops/docker-entrypoint-flags
docker build -t brokenops-entrypoint-flags . >/tmp/brokenops-entrypoint-build.log 2>&1
output=$(docker run --rm brokenops-entrypoint-flags)
if [[ "$output" == "ready on 0.0.0.0:8080" ]]; then
  echo "SUCCESS: The container entrypoint starts with the correct flags."
  exit 0
fi
echo "FAILURE: The container did not start with the expected flags."
exit 1
