#!/bin/bash
sed -i 's/listen 80808 default_server;/listen 80 default_server;/' /etc/nginx/sites-available/default
sed -i 's/listen \[::\]:80808 default_server;/listen \[::\]:80 default_server;/' /etc/nginx/sites-available/default
systemctl restart nginx
