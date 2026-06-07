#!/bin/bash
cp /etc/nginx/ssl/server.key.correct /etc/nginx/ssl/server.key
systemctl restart nginx
