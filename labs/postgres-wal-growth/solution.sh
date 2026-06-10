#!/bin/bash

# Drop the stale replication slot
sudo -u postgres psql -c "SELECT pg_drop_replication_slot('stale_replica');"

# Force a checkpoint to encourage WAL recycling
sudo -u postgres psql -c "CHECKPOINT;"
