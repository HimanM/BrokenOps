### The Issue

Nginx resolved the backend hostname before the backend moved to its new IP address. That first lookup was cached, so the proxy kept sending requests to the old address until Nginx was refreshed.

### Step-by-Step Fix

1. **Confirm the backend hostname now points to the new IP**:
   ```bash
   getent hosts backend.internal.brokenops
   ```

2. **Reload Nginx so it resolves the upstream again**:
   ```bash
   sudo systemctl reload nginx
   ```

3. **Verify the proxy works again**:
   ```bash
   curl -i http://localhost/
   ```

4. **Outcome**:
   Once Nginx reloads, it picks up the updated backend address and the reverse proxy starts returning the backend response again.
