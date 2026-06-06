### The Issue

The website is returning a `403 Forbidden` error because `/var/www/html/index.html` has an incorrect SELinux file security context context (`admin_home_t` instead of `httpd_sys_content_t`).

Under SELinux, a service like Nginx (running under the `httpd_t` domain) is only allowed to read files in the web root that are explicitly labeled with the standard web content context `httpd_sys_content_t`. Files copied from user home directories often carry over home contexts (like `admin_home_t` or `user_home_t`), which SELinux blocks Nginx from reading.

### Step-by-Step Fix

1. **Verify the website access and logs**:
   Query the local web server:
   ```bash
   curl -I http://localhost/
   ```
   You will get a `403 Forbidden` response.
   
   Check the Nginx error logs:
   ```bash
   sudo tail -n 20 /var/log/nginx/error.log
   ```
   You will see a "Permission denied" error for `/var/www/html/index.html`.

2. **Inspect the SELinux audit logs**:
   Locate the AVC denials in `/var/log/audit/audit.log` showing the blocked read operations:
   ```bash
   sudo tail -n 50 /var/log/audit/audit.log | grep AVC
   ```
   You will see a denial indicating that `nginx` was denied `read` access to `index.html` due to target context `admin_home_t`.

3. **Check the file security context**:
   Inspect the context of the file `/var/www/html/index.html`:
   ```bash
   ls -laZ /var/www/html/index.html
   ```
   You will see the context is set to `unconfined_u:object_r:admin_home_t:s0`.

4. **Restore the default SELinux context**:
   Restore the standard context recursively for the entire web root directory:
   ```bash
   sudo restorecon -R /var/www/html
   ```
   Alternatively, you can manually modify it using `chcon`:
   ```bash
   sudo chcon -t httpd_sys_content_t /var/www/html/index.html
   ```

5. **Verify the results**:
   Verify the context has been restored:
   ```bash
   ls -laZ /var/www/html/index.html
   ```
   It should now display `httpd_sys_content_t`.
   
   Confirm the website is accessible:
   ```bash
   curl -I http://localhost/
   ```
   It should return a successful `200 OK` response.
