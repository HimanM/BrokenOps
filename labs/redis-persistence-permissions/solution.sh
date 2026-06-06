#!/bin/bash

# Fix the ownership of the Redis data directory
chown -R redis:redis /var/lib/redis

# Ensure correct permissions
chmod 755 /var/lib/redis

# Reset failed state in systemd to clear rate-limiting
systemctl reset-failed redis-server

# Restart Redis service to apply changes
systemctl restart redis-server
