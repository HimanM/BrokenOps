#!/bin/bash
set -euo pipefail
cd /opt/brokenops/docker-multi-stage-copy-path
docker build -t brokenops-multi-stage-copy . >/tmp/brokenops-multi-stage-build.log 2>&1
docker run --rm brokenops-multi-stage-copy sh -c 'test "$(cat /app/app.txt)" = "BrokenOps multi-stage build"'
echo "SUCCESS: The multi-stage build produces the expected artifact."
exit 0
