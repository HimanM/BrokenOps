### The Issue
PostgreSQL uses Write Ahead Logs (WAL) to ensure data integrity. These logs are normally recycled after a checkpoint. However, if there is a **stale replication slot** (a slot created for a replica that is no longer connected), PostgreSQL will keep all WAL segments from the time the replica last connected to ensure it can catch up. This can quickly fill up the disk.

### Step-by-Step Fix

1. **Verify disk usage**:
   ```bash
   df -h
   sudo du -sh /var/lib/postgresql/*/main/pg_wal
   ```

2. **Check for replication slots**:
   Connect to PostgreSQL and check the status of replication slots.
   ```bash
   sudo -u postgres psql -c "SELECT * FROM pg_replication_slots;"
   ```
   You will see a slot named `stale_replica` that is `active = f`.

3. **Drop the stale slot**:
   Since no replica is using this slot, it can be safely removed.
   ```bash
   sudo -u postgres psql -c "SELECT pg_drop_replication_slot('stale_replica');"
   ```

4. **Force a checkpoint**:
   Encourage PostgreSQL to clean up the now-unneeded WAL files immediately.
   ```bash
   sudo -u postgres psql -c "CHECKPOINT;"
   ```

5. **Verify the fix**:
   Check the `pg_wal` directory size again. It should be significantly smaller.
   ```bash
   sudo du -sh /var/lib/postgresql/*/main/pg_wal
   ```
