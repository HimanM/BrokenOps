#!/bin/bash

# 1. Kill the rogue background process
pkill -f exhaust_connections.py || true

# 2. Terminate all existing backend connections
sudo -u postgres psql -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid();"

# 3. Increase max_connections to prevent future exhaustion
sudo -u postgres psql -c "ALTER SYSTEM SET max_connections = 100;"

# 4. Restart PostgreSQL to apply changes
systemctl restart postgresql
