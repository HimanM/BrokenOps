#!/bin/bash

# Try to connect as 'appuser' with a password (this should fail initially because of 'auth_socket')
# Note: we use -p'any' just to trigger password auth
if mysql -u appuser -p'apppassword' -e "SELECT 1" > /dev/null 2>&1; then
    echo "SUCCESS: appuser can authenticate with a password."
    exit 0
else
    echo "FAILURE: appuser cannot authenticate with a password."
    exit 1
fi
