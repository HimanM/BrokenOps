#!/bin/bash
set -euo pipefail

sed -i 's/^10.255.255.1 backend.internal.brokenops$/10.255.255.2 backend.internal.brokenops/' /etc/hosts
sed -i 's/proxy_pass http:\/\/backend.internal.brokenops:5001;/proxy_pass http:\/\/backend.internal.brokenops:5000;/' /etc/nginx/sites-available/brokenops.conf
systemctl start nginx
