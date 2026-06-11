#!/bin/bash
set -euo pipefail
cd /opt/brokenops/docker-multi-stage-copy-path
docker build -t brokenops-multi-stage-copy . >/tmp/brokenops-multi-stage-build.log 2>&1
output=$(docker run --rm brokenops-multi-stage-copy)
if [[ "$output" == "BrokenOps multi-stage build" ]]; then
  echo "SUCCESS: The multi-stage build produces the expected artifact."
  exit 0
fi
echo "FAILURE: The built image did not return the expected artifact."
exit 1
