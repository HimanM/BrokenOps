#!/bin/bash

# Check if docker service is active
systemctl is-active --quiet docker
if [ $? -ne 0 ]; then
  echo "FAILURE: The docker service is not running."
  exit 1
fi

echo "SUCCESS: The docker service is running correctly!"
exit 0
