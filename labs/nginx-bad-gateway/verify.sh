#!/bin/bash

# Check if Nginx is returning 200 OK
if curl -s -o /dev/null -I -w "%{http_code}" http://localhost | grep -q "200"; then
    echo "SUCCESS: Nginx is serving the application correctly."
    exit 0
else
    echo "FAILURE: Nginx is still returning an error."
    exit 1
fi
