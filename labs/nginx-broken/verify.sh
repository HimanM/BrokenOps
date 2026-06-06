#!/bin/bash

# Check if nginx service is active
systemctl is-active --quiet nginx
if [ $? -ne 0 ]; then
  echo "FAILURE: The nginx service is not running."
  exit 1
fi

# Check if it's actually listening on port 80 for IPv4
ss -tuln -4 | grep ":80 " > /dev/null
if [ $? -ne 0 ]; then
  echo "FAILURE: Nginx is running, but it's not listening on port 80!"
  exit 1
fi

echo "SUCCESS: Nginx is running and listening on port 80!"
exit 0
