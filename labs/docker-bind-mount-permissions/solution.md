### The Issue
The Docker container is running as a non-root user (UID 1000), but the host directory `/opt/app-data` is owned by `root` with restrictive permissions (`700`). This prevents the containerized process from writing to the bind-mounted volume.

### Step-by-Step Fix

1. **Check container logs**:
   Confirm the permission denied error:
   ```bash
   docker logs web-app
   ```

2. **Inspect the container user**:
   Identify which UID the container is running as:
   ```bash
   docker inspect web-app --format '{{.Config.User}}'
   ```

3. **Check host directory permissions**:
   Verify the ownership and permissions of the mount point:
   ```bash
   ls -ld /opt/app-data
   ```

4. **Fix ownership**:
   Change the owner of the host directory to match the container's UID (1000):
   ```bash
   sudo chown 1000:1000 /opt/app-data
   ```

5. **Verify the fix**:
   Wait a few seconds for the container to retry, or restart it:
   ```bash
   docker restart web-app
   ```
   Then check if the `heartbeat` file is created:
   ```bash
   ls -l /opt/app-data/heartbeat
   ```
