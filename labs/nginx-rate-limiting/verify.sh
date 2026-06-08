#!/bin/bash

# Check if nginx is running
if ! systemctl is-active --quiet nginx; then
    echo "FAILURE: Nginx service is not running."
    exit 1
fi

# Test rate limiting
# 1 request should succeed, but rapid follow-ups should fail if no burst is allowed
SUCCESS_COUNT=0
for i in {1..5}; do
    CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1/api/)
    echo "Request $i: HTTP $CODE"
    if [ "$CODE" == "200" ]; then
        ((SUCCESS_COUNT++))
    fi
done

# If more than 1 request succeeded, rate limiting is too lenient (or we fixed it)
if [ "$SUCCESS_COUNT" -le 1 ]; then
    echo "FAILURE: Rate limiting is too aggressive (only $SUCCESS_COUNT/5 requests succeeded)."
    exit 1
fi

echo "SUCCESS: Rate limiting is reasonable ($SUCCESS_COUNT/5 requests succeeded)."
exit 0
