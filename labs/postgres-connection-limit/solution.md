### The Issue
The PostgreSQL server was configured with a very low `max_connections` limit (10), and a rogue Python script was opening multiple idle connections, filling all available slots. Even the `superuser_reserved_connections` were exhausted.

### Step-by-Step Fix

1. **Verify the error**:
   Try connecting to the database manually.
   ```bash
   sudo -u postgres psql
   ```
   If you see `FATAL: sorry, too many clients already`, the limit is reached.

2. **Identify rogue processes**:
   Check for any suspicious scripts running on the system.
   ```bash
   ps aux | grep python
   ```
   You might see `/usr/local/bin/exhaust_connections.py` running.

3. **Terminate the rogue script**:
   ```bash
   sudo pkill -f exhaust_connections.py
   ```

4. **Connect as Superuser and Terminate Backends**:
   PostgreSQL usually reserves some connections for superusers (controlled by `superuser_reserved_connections`). Login as the `postgres` user and kill the idle backends.
   ```bash
   sudo -u postgres psql -c "SELECT pid, state, query FROM pg_stat_activity;"
   ```
   To kill all other connections:
   ```bash
   sudo -u postgres psql -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid();"
   ```

5. **Increase max_connections**:
   The limit of 10 is too low for most applications. Increase it in the configuration.
   ```bash
   sudo -u postgres psql -c "ALTER SYSTEM SET max_connections = 100;"
   ```

6. **Restart PostgreSQL**:
   Changes to `max_connections` require a restart.
   ```bash
   sudo systemctl restart postgresql
   ```

7. **Verify**:
   Check the new limit and ensure you can connect.
   ```bash
   sudo -u postgres psql -c "SHOW max_connections;"
   ```
