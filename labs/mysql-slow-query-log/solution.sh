#!/bin/bash

# Create the missing directory
mkdir -p /var/log/mysql-slow

# Set correct ownership
chown mysql:mysql /var/log/mysql-slow

# Restart MySQL
systemctl restart mysql
