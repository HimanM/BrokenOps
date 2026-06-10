#!/bin/bash

# Update Nginx configuration with CORS support
cat <<EOF > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    server_name _;

    location /api {
        alias /var/www/api;
        default_type application/json;

        if (\$request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' 'https://app.brokenops.io';
            add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Type' 'text/plain; charset=utf-8';
            add_header 'Content-Length' 0;
            return 204;
        }

        if (\$request_method = 'GET') {
            add_header 'Access-Control-Allow-Origin' 'https://app.brokenops.io';
            add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
            add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';
        }
    }
}
EOF

# Test and Restart Nginx
nginx -t && systemctl restart nginx
