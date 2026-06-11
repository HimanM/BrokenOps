#!/bin/bash
set -euo pipefail
cd /opt/brokenops/compose-service-dns-breaks-after-rename
if grep -q '^ENV UPSTREAM_HOST=backend$' proxy/Dockerfile; then
  echo "SUCCESS: Compose uses the updated backend hostname."
  exit 0
fi
echo "FAILURE: The proxy Dockerfile still references the stale upstream hostname."
grep '^ENV UPSTREAM_HOST=' proxy/Dockerfile || true
exit 1
