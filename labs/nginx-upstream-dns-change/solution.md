### The Issue

Nginx is proxying to the wrong upstream port after the backend service moved back to 5000. The hostname is fine, but the reverse proxy still points at the stale port.

### Step-by-Step Fix

1. **Update the proxy target to the correct port**:
   ```bash
   sudo sed -i 's/proxy_pass http:\/\/backend.internal.brokenops:5001;/proxy_pass http:\/\/backend.internal.brokenops:5000;/' /etc/nginx/sites-available/brokenops.conf
   ```

2. **Reload Nginx so it picks up the updated backend port**:
   ```bash
   sudo systemctl reload nginx
   ```

3. **Verify the proxy works again**:
   ```bash
   curl -i http://localhost/
   ```
