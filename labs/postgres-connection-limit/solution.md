### The Issue
PostgreSQL is hitting a low `max_connections` limit, and a background script is consuming most of the available slots. Once the server reaches the ceiling, normal application logins start failing.

### Step-by-Step Fix

1. **Confirm the connection-limit error**:
   Try connecting as the database user and observe the `too many clients already` message.
   ```bash
   sudo -u postgres psql
   ```

2. **Inspect active sessions**:
   Look at the running backends to see which connections are consuming slots.
   ```bash
   sudo -u postgres psql -c "SELECT pid, state, query FROM pg_stat_activity;"
   ```

3. **Stop the sample connection hog if it is still running**:
   If the lab includes a helper script that keeps many connections open, stop it so the recovery path is easy to verify.
   - Optional helper: `sudo pkill -f exhaust_connections.py`

4. **Increase the limit and reload the service**:
   Update `max_connections` to a value that can handle the workload, then restart PostgreSQL because this setting is not applied by a simple reload.
   ```bash
   sudo -u postgres psql -c "ALTER SYSTEM SET max_connections = 100;"
   sudo systemctl restart postgresql
   ```

5. **Verify the fix**:
   Check the new limit and make sure a normal login works again.
   ```bash
   sudo -u postgres psql -c "SHOW max_connections;"
   ```
