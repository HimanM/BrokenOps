#!/bin/bash

# Check if redis service is active
systemctl is-active --quiet redis-server
if [ $? -ne 0 ]; then
  echo "FAILURE: The redis-server service is still not running."
  exit 1
fi

echo "SUCCESS: The redis-server service is running!"
exit 0
