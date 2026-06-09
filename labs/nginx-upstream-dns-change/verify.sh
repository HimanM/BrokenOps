#!/bin/bash
set -euo pipefail

if ! systemctl is-active --quiet nginx; then
  echo "FAILURE: Nginx is not running."
  exit 1
fi

if ! systemctl is-active --quiet brokenops-backend; then
  echo "FAILURE: The backend service is not running."
  exit 1
fi

if ! grep -q '^192.0.2.11 backend.internal.brokenops$' /etc/hosts; then
  echo "FAILURE: The backend hostname does not point to the updated IP address."
  exit 1
fi

RESPONSE=$(curl -fsS http://localhost/)
if [[ "$RESPONSE" != *"BrokenOps backend v2"* ]]; then
  echo "FAILURE: The reverse proxy is still not reaching the backend."
  exit 1
fi

echo "SUCCESS: Nginx is proxying to the updated backend address."
