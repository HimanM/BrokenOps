#!/bin/bash
set -u
if getent hosts api-server | grep -q "10.0.0.50"; then
  echo "SUCCESS: Short hostname 'api-server' resolves to 10.0.0.50"
  exit 0
else
  echo "FAILURE: Cannot resolve short hostname 'api-server'. Check /etc/hosts."
  exit 1
fi
