#!/bin/bash

# Update Nginx configuration with mandatory keepalive proxy settings
sed -i '/proxy_pass/a \            proxy_http_version 1.1;\n            proxy_set_header Connection "";' /etc/nginx/sites-available/default

# Restart Nginx
systemctl restart nginx
