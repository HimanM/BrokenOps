#!/bin/bash

# Attempt to connect to the database as appuser
export PGPASSWORD='apppassword'

if psql -h 127.0.0.1 -U appuser -d appdb -c "SELECT 1;" > /dev/null 2>&1; then
    echo "SUCCESS: appuser successfully connected to appdb!"
    exit 0
else
    echo "FAILURE: appuser failed to connect to appdb. pg_hba.conf might still be rejecting it."
    exit 1
fi
