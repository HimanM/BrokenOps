#!/bin/bash
set -euo pipefail

if ! systemctl is-active --quiet nginx; then
  echo "FAILURE: nginx is not active."
  exit 1
fi

if ! curl -fsS http://127.0.0.1/ | grep -q 'BrokenOps backend'; then
  echo "FAILURE: The reverse proxy is not returning the backend response."
  exit 1
fi

echo "SUCCESS: Nginx is proxying to the backend again."
