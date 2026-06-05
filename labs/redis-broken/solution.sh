#!/bin/bash
sed -i 's/bind 127.0.0.1 256.256.256.256/bind 127.0.0.1 ::1/' /etc/redis/redis.conf
systemctl restart redis-server
