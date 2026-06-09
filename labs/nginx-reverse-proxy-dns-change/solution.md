### The Issue

The backend hostname in `/etc/hosts` points at the wrong address, so Nginx resolves the upstream to a place where nothing is listening. The backend service is fine; the name resolution is stale.

### Step-by-Step Fix

1. **Correct the upstream hostname mapping**:
   ```bash
   sudo sed -i 's/10.255.255.1 api.internal/127.0.0.1 api.internal/' /etc/hosts
   ```
2. **Restart Nginx so it re-resolves the upstream**:
   ```bash
   sudo systemctl restart nginx
   ```
3. **Verify the proxy response**:
   ```bash
   curl -fsS http://127.0.0.1/
   ```
