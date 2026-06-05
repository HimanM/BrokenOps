#!/bin/bash

# Check if nginx service is active
systemctl is-active --quiet nginx
if [ $? -ne 0 ]; then
  echo "FAILURE: nginx service is not running."
  exit 1
fi

# Check if nginx is listening on port 8080
ss -tuln | grep ':8080 ' > /dev/null
if [ $? -ne 0 ]; then
  echo "FAILURE: nginx is not listening on port 8080."
  exit 1
fi

# Check SELinux port context mapping for HTTP on 8080
semanage port -l | awk '/^http_port_t/ && /(^|[^0-9])8080([^0-9]|$)/ {found=1} END {exit found?0:1}'
if [ $? -ne 0 ]; then
  echo "FAILURE: SELinux is not allowing HTTP service on tcp/8080 (http_port_t mapping missing)."
  exit 1
fi

# Check HTTP response over localhost
curl -sSf http://127.0.0.1:8080 > /dev/null
if [ $? -ne 0 ]; then
  echo "FAILURE: nginx is running on 8080 but HTTP request failed."
  exit 1
fi

echo "SUCCESS: nginx is serving on 8080 and SELinux http_port_t mapping is set for tcp/8080."
exit 0
