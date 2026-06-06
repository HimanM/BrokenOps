### The Issue
The Nginx configuration file at `/etc/nginx/sites-available/default` is configured to forward PHP requests via a Unix domain socket at `unix:/run/php/php-fpm-wrong.sock`. However, the default PHP-FPM socket path on Ubuntu 24.04 (running PHP 8.3) is actually `/run/php/php8.3-fpm.sock`. This mismatch causes Nginx to return a `502 Bad Gateway` error because it cannot find or connect to the specified socket.

### Step-by-Step Fix

1. **Verify PHP-FPM Status and Socket Path**:
   Check if the PHP-FPM service is active:
   ```bash
   systemctl status php8.3-fpm
   ```
   List the `/run/php/` directory to see the active socket file:
   ```bash
   ls -la /run/php/
   ```
   You should see `php8.3-fpm.sock` listed there.

2. **Update the Nginx Configuration**:
   Open `/etc/nginx/sites-available/default` in an editor and locate the PHP block. Change the `fastcgi_pass` directive to point to the correct socket:
   ```nginx
   location ~ \.php$ {
       include snippets/fastcgi-php.conf;
       fastcgi_pass unix:/run/php/php8.3-fpm.sock;
   }
   ```
   Alternatively, you can edit it inline using `sed`:
   ```bash
   sudo sed -i 's|unix:/run/php/php-fpm-wrong.sock|unix:/run/php/php8.3-fpm.sock|g' /etc/nginx/sites-available/default
   ```

3. **Verify and Restart Nginx**:
   Test the Nginx configuration for syntax errors:
   ```bash
   sudo nginx -t
   ```
   If successful, restart Nginx to apply changes:
   ```bash
   sudo systemctl restart nginx
   ```

4. **Verify Solution**:
   Curl the PHP endpoint to verify that it successfully processes requests:
   ```bash
   curl http://localhost/index.php
   ```
   It should return `PHP is working!`.
