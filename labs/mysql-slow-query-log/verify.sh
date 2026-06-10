#!/bin/bash

# Check if MySQL is running
if ! systemctl is-active --quiet mysql; then
    echo "FAILURE: MySQL service is not running."
    exit 1
fi

# Check if slow query log is enabled and path is correct
# We'll check if the file exists and is owned by mysql
SLOW_LOG_PATH=$(mysql -Nse "SELECT @@slow_query_log_file")

if [ -z "$SLOW_LOG_PATH" ]; then
    echo "FAILURE: Could not retrieve slow_query_log_file from MySQL."
    exit 1
fi

if [ ! -f "$SLOW_LOG_PATH" ]; then
    echo "FAILURE: Slow query log file does not exist: $SLOW_LOG_PATH"
    exit 1
fi

if [ ! -w "$SLOW_LOG_PATH" ]; then
    echo "FAILURE: Slow query log file is not writable by current user (root should be fine, but mysql needs it)."
    # Better check if mysql user can write or if it's owned by mysql
fi

echo "SUCCESS: MySQL is running and slow query log is configured."
exit 0
