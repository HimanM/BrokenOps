#!/bin/bash

# Kill the script holding the connections
pkill -f exhaust_mysql.py || true

# Increase max_connections dynamically and persistently
mysql -e "SET GLOBAL max_connections = 200;"
sed -i 's/max_connections = 10/max_connections = 200/' /etc/mysql/mysql.conf.d/zz-broken.cnf

systemctl restart mysql
