### The Issue
Apache loads site configurations from the `/etc/apache2/sites-enabled/` directory, typically in alphabetical order. Both the default site (`000-default.conf`) and the custom site (`custom-app.conf`) were configured to handle requests on port 80 for any hostname. Because `000-default.conf` comes first alphabetically, it takes precedence and handles the requests before `custom-app.conf` is even considered.

### Step-by-Step Fix

1. **Verify the current behavior**:
   ```bash
   curl http://localhost
   ```
   You will see the HTML for the "Apache2 Ubuntu Default Page".

2. **Inspect virtual host settings**:
   ```bash
   apache2ctl -S
   ```
   This command displays the virtual host configuration. You will likely see both `000-default.conf` and `custom-app.conf` competing for port 80.

3. **Check enabled sites**:
   ```bash
   ls /etc/apache2/sites-enabled/
   ```
   You will see both `000-default.conf` and `custom-app.conf` linked there.

4. **Disable the default site**:
   To ensure the custom site is used, disable the default configuration.
   ```bash
   sudo a2dissite 000-default.conf
   ```

5. **Reload Apache**:
   Apply the changes by reloading the service.
   ```bash
   sudo systemctl reload apache2
   ```

6. **Verify the fix**:
   ```bash
   curl http://localhost
   ```
   It should now return `<h1>Custom App is Running</h1>`.
