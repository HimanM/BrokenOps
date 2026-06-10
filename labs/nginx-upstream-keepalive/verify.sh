#!/bin/bash

# 1. Check if Nginx configuration contains the necessary directives for keepalive
if ! grep -q "proxy_http_version 1.1;" /etc/nginx/sites-available/default; then
    echo "FAILURE: proxy_http_version 1.1 is missing."
    exit 1
fi

if ! grep -q "proxy_set_header Connection \"\";" /etc/nginx/sites-available/default; then
    echo "FAILURE: proxy_set_header Connection \"\"; is missing."
    exit 1
fi

# 2. Check if the site is returning 200 OK
if curl -s -o /dev/null -I -w "%{http_code}" http://localhost | grep -q "200"; then
    echo "SUCCESS: Nginx is serving correctly with proper keepalive config."
    exit 0
else
    echo "FAILURE: Nginx returned an error code."
    exit 1
fi
