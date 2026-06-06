#!/bin/bash
chown www-data:www-data /var/www/html/index.html
chcon -t httpd_sys_content_t /var/www/html/index.html 2>/dev/null || true
