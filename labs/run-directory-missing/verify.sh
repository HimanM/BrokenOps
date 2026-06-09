#!/bin/bash
set -euo pipefail

if ! systemctl is-active --quiet demo-app.service; then
  echo "FAILURE: demo-app.service is not active."
  exit 1
fi

if [ ! -f /run/demo-app/demo.pid ]; then
  echo "FAILURE: /run/demo-app/demo.pid was not created."
  exit 1
fi

if ! curl -fsS http://127.0.0.1:4000/ | grep -q 'BrokenOps demo app'; then
  echo "FAILURE: The demo app is not serving the expected content."
  exit 1
fi

echo "SUCCESS: The runtime directory exists and the demo app is serving traffic."
