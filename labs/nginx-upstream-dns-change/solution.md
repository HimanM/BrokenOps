### The Issue

Nginx was still sending requests to the old backend address after the hostname moved to a new IP. The stale DNS entry in `/etc/hosts` kept the proxy pointed at the wrong place.

### Step-by-Step Fix

1. **Update the stale hostname mapping**:
   ```bash
   sudo sed -i 's/^10.255.255.1 backend.internal.brokenops$/192.0.2.11 backend.internal.brokenops/' /etc/hosts
   ```

2. **Reload Nginx so it picks up the updated backend address**:
   ```bash
   sudo systemctl reload nginx
   ```

3. **Verify the proxy works again**:
   ```bash
   curl -i http://localhost/
   ```
