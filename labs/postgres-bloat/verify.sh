#!/bin/bash

# Check if autovacuum is enabled globally
AV_STATUS=$(sudo -u postgres psql -t -c "SHOW autovacuum;" | xargs)

if [ "$AV_STATUS" != "on" ]; then
    echo "FAILURE: Autovacuum is still disabled ($AV_STATUS)."
    exit 1
fi

# Check for dead tuples in busy_table
# After a VACUUM, the n_dead_tup should be close to 0
DEAD_TUPLES=$(sudo -u postgres psql -t -c "SELECT n_dead_tup FROM pg_stat_user_tables WHERE relname = 'busy_table';" | xargs)

if [ "$DEAD_TUPLES" -gt 100 ]; then
    echo "FAILURE: busy_table still has $DEAD_TUPLES dead tuples. Manual VACUUM might be needed."
    exit 1
fi

echo "SUCCESS: Autovacuum is enabled and table is cleaned."
exit 0
