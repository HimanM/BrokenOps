### The Issue
The MySQL user account `appuser` was configured to use the `auth_socket` authentication plugin. This plugin requires the database username to match the system username and authenticates via a Unix socket, completely bypassing password checks. Since the application is trying to authenticate with a password, the connection fails.

### Step-by-Step Fix

1. **Verify the error**:
   Try connecting as `appuser` with a password.
   ```bash
   mysql -u appuser -p
   ```
   You will get an error like: `ERROR 1698 (28000): Access denied for user 'appuser'@'localhost'`.

2. **Inspect user configuration**:
   Login as root (which often uses `auth_socket` itself on Ubuntu) and check the `plugin` column in the `mysql.user` table.
   ```bash
   sudo mysql -e "SELECT user, host, plugin FROM mysql.user WHERE user = 'appuser';"
   ```
   You will see `auth_socket` for `appuser`.

3. **Change the authentication plugin**:
   Modify the user to use `mysql_native_password` (or `caching_sha2_password` depending on your MySQL version and client support) and set a password.
   ```bash
   sudo mysql -e "ALTER USER 'appuser'@'localhost' IDENTIFIED WITH 'mysql_native_password' BY 'apppassword';"
   sudo mysql -e "FLUSH PRIVILEGES;"
   ```

4. **Verify the fix**:
   Try connecting again with the password.
   ```bash
   mysql -u appuser -p'apppassword' -e "SELECT 1"
   ```
   The command should now succeed.
