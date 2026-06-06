### The Issue
The target directory for file uploads (`/var/www/html/uploads/`) is owned by `root:root` with permissions `755`. Because the web server and PHP-FPM process run under the unprivileged `www-data` user, the PHP engine does not have write permissions to write files into the `/var/www/html/uploads/` directory, resulting in file upload failure.

### Step-by-Step Fix

1. **Verify the Directory and Permissions**:
   Check the location and permissions of the upload directory:
   ```bash
   ls -ld /var/www/html/uploads
   ```
   You will notice that the directory is owned by `root:root` instead of `www-data:www-data`.

2. **Fix Directory Ownership**:
   Change the ownership of the uploads directory to the web server user `www-data`:
   ```bash
   sudo chown -R www-data:www-data /var/www/html/uploads
   ```

3. **Ensure Correct Permissions**:
   Make sure the directory has write permissions enabled for the owner:
   ```bash
   sudo chmod 755 /var/www/html/uploads
   ```

4. **Verify the Solution**:
   Perform a test upload using `curl`:
   ```bash
   echo "test log content" > /tmp/test.txt
   curl -F "file=@/tmp/test.txt" http://localhost/index.php
   ```
   The server should return `UPLOAD_SUCCESS`.
