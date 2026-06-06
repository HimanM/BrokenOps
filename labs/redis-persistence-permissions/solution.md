### The Issue
The Redis data directory `/var/lib/redis` (where `dump.rdb` is stored) is owned by `root:root` instead of the `redis` user. Because the `redis-server` process runs as the unprivileged `redis` user, it does not have write permissions to this directory. As a result, Redis cannot create or write snapshots (`dump.rdb`) to disk, causing data to be lost when the service restarts.

### Step-by-Step Fix

1. **Verify Redis Persistence Status**:
   Inspect the Redis persistence logs or attempt to manually force a snapshot write:
   ```bash
   redis-cli save
   ```
   You should see an error indicating that Redis cannot save (e.g., `ERR Unknown error` or similar permission errors).
   Alternatively, inspect the logs:
   ```bash
   tail -n 50 /var/log/redis/redis-server.log
   ```
   Look for lines indicating write or permission failures.

2. **Check Permissions of the Data Directory**:
   Check the ownership and permissions of the directory configured in `/etc/redis/redis.conf` (usually `dir /var/lib/redis`):
   ```bash
   ls -ld /var/lib/redis
   ```
   You will notice that the directory is owned by `root:root` instead of `redis:redis`.

3. **Fix Directory Ownership**:
   Change the ownership of `/var/lib/redis` back to the `redis` user:
   ```bash
   sudo chown -R redis:redis /var/lib/redis
   ```

4. **Ensure Correct Permissions**:
   Make sure the directory is writable by the owner:
   ```bash
   sudo chmod 755 /var/lib/redis
   ```

5. **Reset and Restart Redis**:
   If the Redis service has crashed multiple times, systemd may have rate-limited it. Reset the failed state and restart the service:
   ```bash
   sudo systemctl reset-failed redis-server
   sudo systemctl restart redis-server
   ```

6. **Verify the Fix**:
   Write a test key and trigger a save manually:
   ```bash
   redis-cli set test "success"
   redis-cli save
   ```
   The `save` command should now return `OK`.
