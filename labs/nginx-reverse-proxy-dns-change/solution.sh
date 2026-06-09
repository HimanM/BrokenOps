#!/bin/bash
set -euo pipefail

sed -i 's/169.254.254.254 api.internal/127.0.0.1 api.internal/' /etc/hosts
sed -i 's/proxy_pass http:\/\/api.internal:3001;/proxy_pass http:\/\/api.internal:3000;/' /etc/nginx/sites-available/brokenops-proxy
systemctl restart nginx
