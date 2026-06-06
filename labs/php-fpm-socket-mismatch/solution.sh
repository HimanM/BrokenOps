#!/bin/bash

# Update nginx default configuration to use the correct php-fpm socket path
sed -i 's|unix:/run/php/php-fpm-wrong.sock|unix:/run/php/php8.3-fpm.sock|g' /etc/nginx/sites-available/default

# Restart Nginx to apply changes
systemctl restart nginx
