#!/bin/bash
set -euo pipefail

if ! systemctl is-active --quiet docker; then
  echo "FAILURE: Docker service is not running."
  exit 1
fi

if ! systemctl is-active --quiet tinyproxy; then
  echo "FAILURE: tinyproxy service is not running."
  exit 1
fi

env_line=$(systemctl show docker --property=Environment --value)
if [[ "$env_line" != *"HTTP_PROXY=http://127.0.0.1:8888"* ]] || [[ "$env_line" != *"HTTPS_PROXY=http://127.0.0.1:8888"* ]]; then
  echo "FAILURE: Docker daemon proxy environment is missing."
  exit 1
fi

if ! docker pull hello-world >/dev/null 2>&1; then
  echo "FAILURE: Docker image pull still fails."
  exit 1
fi

echo "SUCCESS: Docker daemon proxy is configured and image pull works."
