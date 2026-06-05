#!/bin/bash
set -e

# Keep nginx on custom port 8080
sed -i 's/listen 80 default_server;/listen 8080 default_server;/' /etc/nginx/sites-available/default || true
sed -i 's/listen \[::\]:80 default_server;/listen [::]:8080 default_server;/' /etc/nginx/sites-available/default || true

# Ensure SELinux allows HTTP traffic on tcp/8080
if ! semanage port -l | awk '/^http_port_t/ && /(^|[^0-9])8080([^0-9]|$)/ {found=1} END {exit found?0:1}'; then
  semanage port -a -t http_port_t -p tcp 8080 || semanage port -m -t http_port_t -p tcp 8080
fi

systemctl restart nginx
