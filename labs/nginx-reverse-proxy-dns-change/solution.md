### The Issue

The reverse proxy is not started with the correct upstream details, so the exposed port never serves the backend until both the host mapping and port are corrected.

### Step-by-Step Fix

1. **Update the backend hostname and proxy target**:
   ```bash
   sudo sed -i 's/169.254.254.254 api.internal/127.0.0.1 api.internal/' /etc/hosts
   sudo sed -i 's/proxy_pass http:\/\/api.internal:3001;/proxy_pass http:\/\/api.internal:3000;/' /etc/nginx/sites-available/brokenops-proxy
   ```

2. **Restart Nginx so it uses the corrected upstream**:
   ```bash
   sudo systemctl restart nginx
   ```

3. **Verify the proxy response**:
   ```bash
   curl -fsS http://127.0.0.1/
   ```
