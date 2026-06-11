#!/bin/bash
set -euo pipefail
cd /opt/brokenops/docker-entrypoint-flags
sed -i 's/--bind/--host/' Dockerfile
