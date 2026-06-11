#!/bin/bash
set -euo pipefail
cd /opt/brokenops/compose-service-dns-breaks-after-rename
sed -i 's/UPSTREAM_HOST=web/UPSTREAM_HOST=backend/' proxy/Dockerfile
