#!/bin/bash
set -euo pipefail
cd /opt/brokenops/compose-service-dns-breaks-after-rename
sed -i 's/http:\/\/web:8000/http:\/\/backend:8000/' proxy/Dockerfile
