#!/bin/bash

# Check if port 80 is accessible locally
if ! curl -s -o /dev/null -I -w "%{http_code}" http://localhost | grep -q "200"; then
    echo "FAILURE: Nginx is not responding locally on port 80."
    exit 1
fi

# THE REAL TEST: Check the iptables rule order
# We want to ensure that the ACCEPT rule for port 80 comes BEFORE any DROP rule that would match it.
# We'll check the rule numbers.
# We use head -n 1 to ensure we only get one line in case of multiple matches
DROP_LINE=$(iptables -L INPUT --line-numbers -n | grep "DROP" | grep "dpts:80:100" | awk '{print $1}' | head -n 1)
ACCEPT_LINE=$(iptables -L INPUT --line-numbers -n | grep "ACCEPT" | grep "dpt:80" | awk '{print $1}' | head -n 1)

if [ -z "$DROP_LINE" ]; then
    # If there's no drop rule, it's 'fixed' or never broken
    echo "SUCCESS: No blocking rule found for port 80."
    exit 0
fi

if [ -n "$ACCEPT_LINE" ] && [ "$ACCEPT_LINE" -lt "$DROP_LINE" ]; then
    echo "SUCCESS: Allow rule for port 80 correctly precedes drop rules."
    exit 0
else
    echo "FAILURE: Port 80 is blocked by a drop rule at line $DROP_LINE before the allow rule at line $ACCEPT_LINE."
    exit 1
fi
