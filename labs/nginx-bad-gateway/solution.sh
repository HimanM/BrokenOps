#!/bin/bash

# Update Nginx configuration to point to the correct backend port (8081)
sed -i 's/127.0.0.1:8080/127.0.0.1:8081/' /etc/nginx/sites-available/default

# Restart Nginx
systemctl restart nginx
