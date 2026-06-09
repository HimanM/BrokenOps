### The Issue

Nginx is not started with the correct upstream configuration, so the exposed port never serves the backend until the service is brought up with the right host mapping and port.

### Step-by-Step Fix

1. **Update the backend hostname and proxy target**:
   ```bash
   sudo sed -i 's/^10.255.255.1 backend.internal.brokenops$/10.255.255.2 backend.internal.brokenops/' /etc/hosts
   sudo sed -i 's/proxy_pass http:\/\/backend.internal.brokenops:5001;/proxy_pass http:\/\/backend.internal.brokenops:5000;/' /etc/nginx/sites-available/brokenops.conf
   ```

2. **Start Nginx so the proxy becomes reachable**:
   ```bash
   sudo systemctl start nginx
   ```

3. **Verify the proxy works again**:
   ```bash
   curl -i http://localhost/
   ```
