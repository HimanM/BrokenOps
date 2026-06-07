#!/bin/bash

# Try to connect as postgres user
if ! sudo -u postgres psql -c "SELECT 1" > /dev/null 2>&1; then
    echo "FAILURE: Cannot connect to PostgreSQL. Connection limit might still be reached or service is down."
    exit 1
fi

# Check current connection count and max_connections
RESULT=$(sudo -u postgres psql -t -A -c "SELECT count(*), (SELECT setting FROM pg_settings WHERE name = 'max_connections') FROM pg_stat_activity")
COUNT=$(echo $RESULT | cut -d'|' -f1)
LIMIT=$(echo $RESULT | cut -d'|' -f2)

# If connections are still exhausted (or very close), fail.
# In our lab, we filled 10/10. Success means significantly fewer or higher limit.
if [ "$COUNT" -ge "$LIMIT" ]; then
    echo "FAILURE: Connections are still exhausted ($COUNT/$LIMIT)."
    exit 1
fi

echo "SUCCESS: PostgreSQL is healthy and accepting connections ($COUNT/$LIMIT)."
exit 0
