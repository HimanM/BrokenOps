#!/bin/bash

# Test connection as appuser
if mysql -u appuser -p'apppassword' -e "SELECT 1;" > /dev/null 2>&1; then
    echo "SUCCESS: Appuser can connect to MySQL!"
    exit 0
else
    echo "FAILURE: Appuser cannot connect, likely due to too many connections."
    exit 1
fi
