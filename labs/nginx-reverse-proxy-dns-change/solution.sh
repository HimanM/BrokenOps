#!/bin/bash
set -euo pipefail

sed -i 's/proxy_pass http:\/\/api.internal:3001;/proxy_pass http:\/\/api.internal:3000;/' /etc/nginx/sites-available/brokenops-proxy
systemctl restart nginx
