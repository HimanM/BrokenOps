### The Issue
MySQL was configured with a `max_connections` value that is too low for the workload in the lab. A small pool of persistent connections fills the server quickly, so new application connections fail with `Too many connections`.

### Step-by-Step Fix

1. **Confirm the failure**:
   Try connecting as the application user and note the connection-limit error.
   ```bash
   mysql -u appuser -p'apppassword'
   ```

2. **Check the current limit**:
   Once you can reach the server as root, inspect the running value.
   ```sql
   SHOW VARIABLES LIKE 'max_connections';
   ```

3. **If the demo load is still running, stop it first**:
   The lab may include a sample script that is holding connections open. If you see it running, stop that workload before re-testing so you can observe the effect of the config change clearly.
   - Optional helper: `sudo pkill -f exhaust_mysql.py`

4. **Raise the connection limit**:
   Increase `max_connections` to a practical value. You can do this temporarily with SQL, then make it persistent in the MySQL config file.
   - Optional helper: edit the config under `/etc/mysql/mysql.conf.d/` so the new value survives a reboot.

5. **Restart MySQL if needed and verify**:
   If you changed the config file, restart the service, then retry the application login and confirm the server accepts new connections again.
   ```bash
   sudo systemctl restart mysql
   mysql -u appuser -p'apppassword' -e "SELECT 1;"
   ```
