### The Issue
CORS is a security mechanism that allows a web page from one origin to access resources from a different origin. By default, browsers block these requests unless the server explicitly allows them via `Access-Control-*` headers.

For "non-simple" requests (like those with JSON content type), the browser first sends a **preflight** `OPTIONS` request to check the server's permissions. If the server doesn't respond correctly to the `OPTIONS` request or doesn't include the `Access-Control-Allow-Origin` header in the actual request, the call fails.

### Step-by-Step Fix

1. **Simulate a preflight request**:
   ```bash
   curl -X OPTIONS -H "Origin: https://app.brokenops.io" -H "Access-Control-Request-Method: GET" -I http://localhost/api/data.json
   ```
   You will notice that Nginx returns a `405 Method Not Allowed` or a standard `200 OK` but without any CORS headers.

2. **Update the Nginx configuration**:
   Add a block inside your `location /api` to handle both preflight and actual requests.
   ```nginx
   location /api {
       alias /var/www/api;
       default_type application/json;

       if ($request_method = 'OPTIONS') {
           add_header 'Access-Control-Allow-Origin' 'https://app.brokenops.io';
           add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
           add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
           add_header 'Access-Control-Max-Age' 1728000;
           add_header 'Content-Type' 'text/plain; charset=utf-8';
           add_header 'Content-Length' 0;
           return 204;
       }

       if ($request_method = 'GET') {
           add_header 'Access-Control-Allow-Origin' 'https://app.brokenops.io';
           add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
           add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
       }
   }
   ```

3. **Reload Nginx**:
   ```bash
   sudo nginx -t
   sudo systemctl restart nginx
   ```

4. **Verify the fix**:
   Repeat the preflight and GET requests. Both should now contain the `Access-Control-Allow-Origin: https://app.brokenops.io` header.
