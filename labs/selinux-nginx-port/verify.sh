#!/bin/bash

# 1. Check if nginx is active
if ! systemctl is-active --quiet nginx; then
  echo "FAILURE: Nginx service is not running."
  exit 1
fi

# 2. Check if nginx is listening on port 8080
if ! ss -tuln | grep -q ':8080 '; then
  echo "FAILURE: Nginx is not listening on port 8080."
  exit 1
fi

# 3. Check if 8080 is in the allowed ports list (semanage check)
if ! grep -Fxq "8080" /etc/selinux/allowed_ports.txt 2>/dev/null; then
  echo "FAILURE: Port 8080 has not been added to the SELinux http_port_t allowed ports list."
  exit 1
fi

# 4. Check HTTP response
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080)
if [ "$response" != "200" ]; then
  echo "FAILURE: HTTP request to http://localhost:8080 returned status $response, expected 200."
  exit 1
fi

echo "SUCCESS: Nginx is listening on port 8080, and the SELinux port mapping has been corrected!"
exit 0
