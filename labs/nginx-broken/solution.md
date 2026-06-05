### The Issue

The developer or someone else accidentally configured Nginx to listen on a port that it doesn't have permission to bind to, or they made a syntax error in the configuration file!

### Step-by-Step Fix

1. **Check the service status to get a hint:**
   ```bash
   systemctl status nginx
   ```
   You should see it failing.

2. **Test the Nginx configuration for syntax errors:**
   ```bash
   sudo nginx -t
   ```
   This will pinpoint exactly which file and line number contains the bad configuration. You'll likely see an error pointing to `/etc/nginx/sites-available/default` trying to listen on port `80808` or a typo like `lissten 80`.

3. **Fix the configuration file:**
   Open the file with your favorite editor:
   ```bash
   sudo nano /etc/nginx/sites-available/default
   ```
   Find the incorrect line and fix it back to listening on a standard port like `80`:
   ```nginx
   server {
       listen 80 default_server;
       listen [::]:80 default_server;
       # ...
   }
   ```

4. **Restart the Nginx service:**
   ```bash
   sudo systemctl restart nginx
   ```

5. **Verify it's running:**
   ```bash
   systemctl status nginx
   ```
   It should now say **active (running)**. You've solved the lab!
