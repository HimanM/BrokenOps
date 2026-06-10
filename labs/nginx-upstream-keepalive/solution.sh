#!/bin/bash

# Update Nginx configuration with mandatory keepalive proxy settings
# We'll use a temporary file to rebuild the location block correctly
cat <<EOF > /etc/nginx/sites-available/default
upstream backend_nodes {
    server 127.0.0.1:8081;
    keepalive 32;
}

server {
    listen 80 default_server;
    server_name _;

    location / {
        proxy_pass http://backend_nodes;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }
}
EOF

# Test and Restart Nginx
nginx -t && systemctl restart nginx
