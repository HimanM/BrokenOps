### The Issue
PostgreSQL uses Multi-Version Concurrency Control (MVCC), which means that when a row is updated or deleted, the old version of the row (a "tuple") remains on disk until it is "vacuumed". If the **autovacuum** daemon is disabled, these dead tuples accumulate, leading to "bloat". This increases disk usage and slows down index scans.

### Step-by-Step Fix

1. **Check if autovacuum is enabled**:
   ```bash
   sudo -u postgres psql -c "SHOW autovacuum;"
   ```
   You will see that it is set to `off`.

2. **Inspect table bloat**:
   Check the number of dead tuples in the `busy_table`.
   ```bash
   sudo -u postgres psql -c "SELECT relname, n_live_tup, n_dead_tup FROM pg_stat_user_tables WHERE relname = 'busy_table';"
   ```
   The `n_dead_tup` column will show a significant number of unreclaimed rows.

3. **Enable autovacuum globally**:
   ```bash
   sudo -u postgres psql -c "ALTER SYSTEM SET autovacuum = on;"
   ```

4. **Reload configuration**:
   ```bash
   sudo -u postgres psql -c "SELECT pg_reload_conf();"
   ```

5. **Perform manual cleanup**:
   While autovacuum will now handle future changes, run a manual vacuum to clean up the existing bloat immediately.
   ```bash
   sudo -u postgres psql -c "VACUUM ANALYZE busy_table;"
   ```

6. **Verify the fix**:
   Check the dead tuple count again.
   ```bash
   sudo -u postgres psql -c "SELECT relname, n_live_tup, n_dead_tup FROM pg_stat_user_tables WHERE relname = 'busy_table';"
   ```
   `n_dead_tup` should now be 0 or very close to it.
