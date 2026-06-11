#!/bin/bash
set -euo pipefail
cd /opt/brokenops/docker-multi-stage-copy-path
if ! docker build -t brokenops-multi-stage-copy . >/tmp/brokenops-multi-stage-build.log 2>&1; then
  cat /tmp/brokenops-multi-stage-build.log
  exit 1
fi
if ! docker run --rm brokenops-multi-stage-copy sh -c 'test "$(cat /app/app.txt)" = "BrokenOps multi-stage build"'; then
  docker run --rm brokenops-multi-stage-copy cat /app/app.txt || true
  exit 1
fi
echo "SUCCESS: The multi-stage build produces the expected artifact."
exit 0
