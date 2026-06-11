### The Issue
The application uses an `.htaccess` file with `RewriteRule` directives to map all requests to `index.php`. However, for these rules to work, two things must be true:
1.  The Apache **rewrite module** (`mod_rewrite`) must be enabled.
2.  The virtual host configuration must allow overrides (using `AllowOverride All` or `AllowOverride FileInfo`).

In this case, the virtual host configuration was correct, but the `rewrite` module itself was not enabled in the Apache server.

### Step-by-Step Fix

1. **Verify the error**:
   Try to visit a non-existent file that should be routed.
   ```bash
   curl -I http://localhost/test-route
   ```
   You will receive a `404 Not Found`.

2. **Check enabled modules**:
   List all active Apache modules and search for `rewrite`.
   ```bash
   apache2ctl -M | grep rewrite
   ```
   If it returns nothing, the module is disabled.

3. **Enable the rewrite module**:
   ```bash
   sudo a2enmod rewrite
   ```

4. **Restart Apache**:
   Apply the changes by restarting the service.
   ```bash
   sudo systemctl restart apache2
   ```

5. **Verify the fix**:
   Test the route again.
   ```bash
   curl http://localhost/test-route
   ```
   It should now return `Welcome to the App: /test-route`.
