#!/bin/bash

# Create the missing directory
mkdir -p /var/log/mysql-slow

# Set correct ownership
chown mysql:mysql /var/log/mysql-slow

# Pre-create the log file to satisfy verification immediately
touch /var/log/mysql-slow/slow.log
chown mysql:mysql /var/log/mysql-slow/slow.log
chmod 640 /var/log/mysql-slow/slow.log

# Restart MySQL
systemctl restart mysql
