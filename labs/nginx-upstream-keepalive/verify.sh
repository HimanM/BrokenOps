#!/bin/bash

# 1. Check if Nginx configuration contains the necessary directives for keepalive
# We use grep -v to ignore commented out lines and ensure the directive is actually there
if ! grep "proxy_http_version 1.1;" /etc/nginx/sites-available/default | grep -qv "#"; then
    echo "FAILURE: proxy_http_version 1.1 is missing or commented out."
    exit 1
fi

if ! grep "proxy_set_header Connection \"\";" /etc/nginx/sites-available/default | grep -qv "#"; then
    echo "FAILURE: proxy_set_header Connection \"\"; is missing or commented out."
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
