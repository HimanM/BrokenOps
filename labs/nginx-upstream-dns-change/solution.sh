#!/bin/bash
set -euo pipefail

sed -i 's/proxy_pass http:\/\/backend.internal.brokenops:5001;/proxy_pass http:\/\/backend.internal.brokenops:5000;/' /etc/nginx/sites-available/brokenops.conf
systemctl reload nginx
