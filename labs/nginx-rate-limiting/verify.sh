#!/bin/bash

# Test rate limiting
# 1 request should succeed, but rapid follow-ups should fail if no burst is allowed
SUCCESS_COUNT=0
for i in {1..5}; do
    if curl -s -o /dev/null -w "%{http_code}" http://localhost/api/ | grep -q "200"; then
        ((SUCCESS_COUNT++))
    fi
done

# If only 1 out of 5 succeeded, rate limiting is still too aggressive
if [ "$SUCCESS_COUNT" -le 1 ]; then
    echo "FAILURE: Rate limiting is too aggressive (only $SUCCESS_COUNT/5 requests succeeded)."
    exit 1
fi

echo "SUCCESS: Rate limiting is reasonable ($SUCCESS_COUNT/5 requests succeeded)."
exit 0
