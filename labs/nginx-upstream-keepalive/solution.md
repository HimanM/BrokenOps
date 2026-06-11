### The Issue
Nginx can maintain a pool of idle keepalive connections to upstream servers to improve performance. However, for this to work correctly with HTTP, Nginx must use **HTTP/1.1** for the proxy requests (it uses 1.0 by default) and the `Connection` header must be cleared (otherwise Nginx passes "close" or the client's header through, which breaks the keepalive logic).

Without `proxy_http_version 1.1;` and `proxy_set_header Connection "";`, Nginx will still try to keep connections in its pool, but they will be in an invalid state or closed by the backend, leading to intermittent 502 errors when Nginx tries to reuse them.

### Step-by-Step Fix

1. **Verify the error**:
   Check the Nginx error logs.
   ```bash
   sudo tail -f /var/log/nginx/error.log
   ```
   You will see errors like: `upstream prematurely closed connection while reading response header`.

2. **Inspect the configuration**:
   ```bash
   cat /etc/nginx/sites-available/default
   ```
   Notice that the `upstream` block has `keepalive 32;`, but the `location` block is missing the necessary `proxy_http_version` and `Connection` header settings.

3. **Update the configuration**:
   Edit `/etc/nginx/sites-available/default` and add the missing directives inside the `location /` block:
   ```nginx
   location / {
       proxy_pass http://backend_nodes;
       proxy_http_version 1.1;
       proxy_set_header Connection "";
   }
   ```

4. **Test and reload Nginx**:
   ```bash
   sudo nginx -t
   sudo systemctl restart nginx
   ```

5. **Verify the fix**:
   ```bash
   curl -I http://localhost
   ```
   The response should now be reliably `200 OK`.
