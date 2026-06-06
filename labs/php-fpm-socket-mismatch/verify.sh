#!/bin/bash

# Check Nginx status
if ! systemctl is-active --quiet nginx; then
  echo "FAILURE: Nginx service is not active"
  exit 1
fi

# Check PHP-FPM status (on Ubuntu 24.04, php8.3-fpm is default)
if ! systemctl is-active --quiet php8.3-fpm; then
  echo "FAILURE: php8.3-fpm service is not active"
  exit 1
fi

# Check HTTP response code and content
RESPONSE=$(curl -s http://localhost/index.php)
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/index.php)

if [ "$HTTP_STATUS" != "200" ]; then
  echo "FAILURE: Accessing index.php returned HTTP status $HTTP_STATUS (expected 200)"
  exit 1
fi

# Ensure that the PHP script was actually executed by the PHP parser and not served as static raw text
if [[ "$RESPONSE" == *"<?php"* ]]; then
  echo "FAILURE: PHP script is not being parsed; served as plain text instead"
  exit 1
fi

if [[ "$RESPONSE" != *"PHP is working!"* ]]; then
  echo "FAILURE: Accessing index.php returned incorrect content: $RESPONSE"
  exit 1
fi

echo "SUCCESS: PHP-FPM is communicating correctly with Nginx and serving PHP content"
exit 0
