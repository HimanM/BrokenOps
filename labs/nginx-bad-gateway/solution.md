### The Issue
Nginx was configured to forward requests to a backend application on port `8080`, but the actual application was listening on port `8081`. This caused Nginx to receive a "Connection refused" error when attempting to reach the upstream server, resulting in the `502 Bad Gateway` error for users.

### Step-by-Step Fix

1. **Verify the error**:
   Check the HTTP response from the server.
   ```bash
   curl -I http://localhost
   ```
   You will see `HTTP/1.1 502 Bad Gateway`.

2. **Inspect Nginx logs**:
   Look at the error logs to see what's happening behind the scenes.
   ```bash
   sudo tail -n 20 /var/log/nginx/error.log
   ```
   You will see an entry like: `connect() failed (111: Connection refused) while connecting to upstream, client: 127.0.0.1, server: _, request: "HEAD / HTTP/1.1", upstream: "http://127.0.0.1:8080/"`.

3. **Check listening ports**:
   Identify which ports are actually being used on the system.
   ```bash
   sudo ss -tlnp
   ```
   You will notice Nginx on port `80` and a Python process (`backend.py`) on port `8081`, but nothing on port `8080`.

4. **Correct the configuration**:
   Edit the Nginx site configuration to point to the correct port.
   ```bash
   sudo vi /etc/nginx/sites-available/default
   ```
   Change `proxy_pass http://127.0.0.1:8080;` to `proxy_pass http://127.0.0.1:8081;`.

5. **Apply changes**:
   Restart Nginx to pick up the new configuration.
   ```bash
   sudo systemctl restart nginx
   ```

6. **Verify the fix**:
   Check the site again.
   ```bash
   curl -I http://localhost
   ```
   It should now return `HTTP/1.1 200 OK`.
