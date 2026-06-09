#!/bin/bash
set -u
cd /opt/brokenops
if output="$(docker compose config 2>&1)"; then
  echo "SUCCESS: Docker Compose configuration is valid and required environment variables are defined."
  exit 0
else
  echo "FAILURE: Docker Compose still has missing environment variables."
  printf '%s\n' "$output"
  exit 1
fi
