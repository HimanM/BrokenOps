### Scenario
A high-traffic application is experiencing slow queries on its primary data table, `busy_table`. The monitoring team noticed that the database disk usage is unusually high, and query execution plans show that indices are becoming less effective. This often points to "table bloat".

### Objective
Diagnose the cause of the bloat, confirm if autovacuum is running, and restore the database to a healthy state by re-enabling automatic maintenance and cleaning up the current bloat.

### Useful Commands
- `sudo -u postgres psql -c "SHOW autovacuum;"`
- `sudo -u postgres psql -c "SELECT relname, n_live_tup, n_dead_tup FROM pg_stat_user_tables WHERE relname = 'busy_table';"`
- `sudo -u postgres psql -c "ALTER SYSTEM SET autovacuum = on;"`
- `sudo -u postgres psql -c "SELECT pg_reload_conf();"`
- `sudo -u postgres psql -c "VACUUM ANALYZE busy_table;"`
