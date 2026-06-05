### The Issue
The app container runs as UID `1000`, but `/srv/app-data` on the host is owned by `root:root` with mode `700`. That means only root on the host can write to the directory, so the non-root container process gets `Permission denied`.

### Step-by-Step Fix

1. **Reproduce the failure**:
   ```bash
   /usr/local/bin/run-app.sh
   ```

2. **Inspect host mount permissions**:
   ```bash
   ls -ld /srv/app-data
   ```

3. **Option A (recommended): align host ownership with container UID**:
   ```bash
   chown 1000:1000 /srv/app-data
   chmod 755 /srv/app-data
   ```

   **Option B:** keep host ownership and run the container as a user that can write there (for example root) by adjusting `/usr/local/bin/run-app.sh`.

4. **Retest writes**:
   ```bash
   /usr/local/bin/run-app.sh
   cat /srv/app-data/result.txt
   ```
   You should see `app-write-ok`.
