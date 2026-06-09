#!/bin/bash
set -euo pipefail
if grep -q '^BROKENOPS_IMAGE=[^[:space:]]\+' /opt/brokenops/.env && \
   grep -q '^BROKENOPS_PORT=[^[:space:]]\+' /opt/brokenops/.env; then
  echo "SUCCESS: Docker Compose configuration is valid and required environment variables are defined."
  exit 0
else
  echo "FAILURE: Docker Compose still has missing environment variables."
  cat /opt/brokenops/.env 2>/dev/null || true
  exit 1
fi
