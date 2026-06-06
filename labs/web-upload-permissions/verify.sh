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

# Check HTTP status of main page
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/index.php)
if [ "$HTTP_STATUS" != "200" ]; then
  echo "FAILURE: Accessing index.php returned HTTP status $HTTP_STATUS"
  exit 1
fi

# Attempt a file upload
echo "verification file" > /tmp/test_verify.txt
RESPONSE=$(curl -s -F "file=@/tmp/test_verify.txt" http://localhost/index.php)
rm -f /tmp/test_verify.txt

if [[ "$RESPONSE" == *"UPLOAD_SUCCESS"* ]]; then
  # Clean up the uploaded file if it was created
  rm -f /var/www/html/uploads/test_verify.txt
  echo "SUCCESS: File upload completed successfully."
  exit 0
else
  echo "FAILURE: File upload failed. Response: $RESPONSE"
  exit 1
fi
