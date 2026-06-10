#!/bin/bash

# Check if the stale replication slot still exists
SLOT_EXISTS=$(sudo -u postgres psql -t -c "SELECT count(*) FROM pg_replication_slots WHERE slot_name = 'stale_replica';" | xargs)

if [ "$SLOT_EXISTS" -ne 0 ]; then
    echo "FAILURE: Stale replication slot 'stale_replica' still exists, preventing WAL cleanup."
    exit 1
fi

echo "SUCCESS: Stale replication slot removed."
exit 0
