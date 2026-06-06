#!/bin/bash

# Check if redis-server is active
if ! systemctl is-active --quiet redis-server; then
  echo "FAILURE: redis-server service is not running."
  exit 1
fi

# Set a test key
redis-cli set verify_persist_test "working_persistence" > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "FAILURE: Failed to write to Redis database."
  exit 1
fi

# Force save
redis-cli save > /dev/null 2>&1

# Restart Redis service to test durability
systemctl restart redis-server
if [ $? -ne 0 ]; then
  echo "FAILURE: Failed to restart redis-server service."
  exit 1
fi

# Verify key persistence
VAL=$(redis-cli get verify_persist_test)
if [ "$VAL" = "working_persistence" ]; then
  # Clean up
  redis-cli del verify_persist_test > /dev/null 2>&1
  echo "SUCCESS: Redis successfully persisted data to disk across restart."
  exit 0
else
  echo "FAILURE: Redis did not persist data to disk. Keys were lost after restart."
  exit 1
fi
