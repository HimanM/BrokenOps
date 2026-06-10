### Scenario
The monitoring system has alerted us that the PostgreSQL database server is running out of disk space on the data partition. After investigation, you find that the `pg_wal` (or `pg_xlog`) directory contains a large number of WAL segments that aren't being cleaned up or recycled.

### Objective
Identify why PostgreSQL is failing to recycle WAL segments and fix the issue to free up disk space.

### Useful Commands
- `df -h`
- `sudo du -sh /var/lib/postgresql/*/main/pg_wal`
- `sudo -u postgres psql -c "SELECT * FROM pg_replication_slots;"`
- `sudo -u postgres psql -c "SELECT pg_drop_replication_slot('slot_name');"`
- `sudo -u postgres psql -c "CHECKPOINT;"`
