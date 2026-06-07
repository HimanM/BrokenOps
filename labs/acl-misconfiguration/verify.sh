#!/bin/bash
if sudo -u webapp touch /var/log/webapp/test_file > /dev/null 2>&1; then
    echo "SUCCESS: webapp user can write to /var/log/webapp"
    rm /var/log/webapp/test_file
    exit 0
else
    echo "FAILURE: webapp user cannot write to /var/log/webapp"
    exit 1
fi
