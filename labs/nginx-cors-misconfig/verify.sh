#!/bin/bash

# 1. Simulate a preflight request from app.brokenops.io
# We expect 204 No Content or 200 OK with specific headers
PREFLIGHT_RESP=$(curl -s -X OPTIONS -H "Origin: https://app.brokenops.io" \
    -H "Access-Control-Request-Method: GET" \
    -I http://localhost/api/data.json)

if ! echo "$PREFLIGHT_RESP" | grep -qi "Access-Control-Allow-Origin: https://app.brokenops.io"; then
    echo "FAILURE: Preflight request missing Access-Control-Allow-Origin header."
    exit 1
fi

if ! echo "$PREFLIGHT_RESP" | grep -qi "Access-Control-Allow-Methods:"; then
    echo "FAILURE: Preflight request missing Access-Control-Allow-Methods header."
    exit 1
fi

# 2. Simulate an actual GET request
GET_RESP=$(curl -s -H "Origin: https://app.brokenops.io" -I http://localhost/api/data.json)

if ! echo "$GET_RESP" | grep -qi "Access-Control-Allow-Origin: https://app.brokenops.io"; then
    echo "FAILURE: Actual request missing Access-Control-Allow-Origin header."
    exit 1
fi

echo "SUCCESS: CORS headers are correctly configured."
exit 0
