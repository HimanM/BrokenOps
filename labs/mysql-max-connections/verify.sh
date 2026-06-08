#!/bin/bash

# 1. Check if the connection-exhaustion script is still running
if pgrep -f exhaust_mysql.py > /dev/null; then
    echo "FAILURE: The connection exhaustion script is still running."
    exit 1
fi

# 2. Check if max_connections was increased to >= 200
MAX_CONN=$(mysql -u root -sN -e "SELECT @@max_connections;")
if [ -z "$MAX_CONN" ] || [ "$MAX_CONN" -lt 200 ]; then
    echo "FAILURE: max_connections is $MAX_CONN, expected >= 200."
    exit 1
fi

# 3. Test connection as appuser
if mysql -u appuser -p'apppassword' -e "SELECT 1;" > /dev/null 2>&1; then
    echo "SUCCESS: Appuser can connect and limits are correct!"
    exit 0
else
    echo "FAILURE: Appuser cannot connect."
    exit 1
fi
