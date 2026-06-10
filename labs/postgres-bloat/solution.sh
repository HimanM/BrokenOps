#!/bin/bash

# 1. Enable autovacuum globally
sudo -u postgres psql -c "ALTER SYSTEM SET autovacuum = on;"

# 2. Reload configuration to apply the change
sudo -u postgres psql -c "SELECT pg_reload_conf();"

# 3. Run manual VACUUM ANALYZE to clean up existing dead tuples immediately
sudo -u postgres psql -c "VACUUM ANALYZE busy_table;"
