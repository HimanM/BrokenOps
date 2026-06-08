#!/bin/bash

# Increase the rate and add a burst parameter
sed -i 's/rate=1r\/s/rate=10r\/s/' /etc/nginx/conf.d/rate_limit.conf
sed -i 's/limit_req zone=mylimit;/limit_req zone=mylimit burst=10 nodelay;/' /etc/nginx/sites-available/default

# Restart nginx
systemctl restart nginx
