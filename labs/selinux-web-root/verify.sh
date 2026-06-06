#!/bin/bash

# 1. Check if nginx is active
if ! systemctl is-active --quiet nginx; then
  echo "FAILURE: Nginx service is not running."
  exit 1
fi

# 2. Check if index.html is readable by www-data
if ! sudo -u www-data test -r /var/www/html/index.html; then
  echo "FAILURE: The Nginx web server user cannot read /var/www/html/index.html."
  exit 1
fi

# 3. Check if the SELinux context of /var/www/html/index.html is restored to httpd_sys_content_t
context=$(grep -F "/var/www/html/index.html" /etc/selinux/file_contexts.txt | awk '{print $2}' | cut -d: -f3)
if [ "$context" != "httpd_sys_content_t" ]; then
  echo "FAILURE: The SELinux file context of /var/www/html/index.html is '$context', expected 'httpd_sys_content_t'."
  exit 1
fi

# 4. Check HTTP response
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/)
if [ "$response" != "200" ]; then
  echo "FAILURE: HTTP request to http://localhost/ returned status $response, expected 200."
  exit 1
fi

echo "SUCCESS: The web root file permissions and SELinux contexts have been successfully restored!"
exit 0
