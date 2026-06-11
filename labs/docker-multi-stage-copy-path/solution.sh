#!/bin/bash
set -euo pipefail
cd /opt/brokenops/docker-multi-stage-copy-path
sed -i 's/app.tx/app.txt/' Dockerfile
