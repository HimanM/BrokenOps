### The Issue

The reverse proxy is pointed at the wrong backend port, so requests hit nothing until Nginx is reconfigured. The backend itself is fine.

### Step-by-Step Fix

1. **Update the proxy target to the correct port**:
   ```bash
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
