#!/bin/bash
sed -i 's/bind 256.256.256.256/bind 0.0.0.0/' /etc/redis/redis.conf
systemctl reset-failed redis-server.service
systemctl restart redis-server
