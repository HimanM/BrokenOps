#!/bin/bash

# Try to connect as normal user 'appuser'
# This should fail if all user slots are taken
export PGPASSWORD='apppassword'
if ! psql -h localhost -U appuser -d postgres -c "SELECT 1" > /dev/null 2>&1; then
    echo "FAILURE: Application user cannot connect to PostgreSQL. Connection limit might be reached."
    exit 1
fi

echo "SUCCESS: Application user can connect to PostgreSQL!"
exit 0
