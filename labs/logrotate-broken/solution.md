### The Issue
The custom logrotate configuration at `/etc/logrotate.d/noisy-app` contains a syntax error. It uses the option `missing_ok` (with an underscore) instead of the correct logrotate option `missingok` (no underscore). When logrotate parses this file, it fails with a configuration parsing error, preventing the rotation from occurring.

### Step-by-Step Fix

1. **Debug the Logrotate Configuration**:
   Run a dry-run check of the logrotate configuration using the debug flag (`-d`):
   ```bash
   logrotate -d /etc/logrotate.d/noisy-app
   ```
   You should see output similar to:
   ```text
   error: /etc/logrotate.d/noisy-app:4 unknown option 'missing_ok'
   ```

2. **Fix the Typo in the Config File**:
   Open `/etc/logrotate.d/noisy-app` in an editor and change `missing_ok` to `missingok`.
   Alternatively, you can edit it inline using `sed`:
   ```bash
   sudo sed -i 's/missing_ok/missingok/g' /etc/logrotate.d/noisy-app
   ```

3. **Verify and Force Rotation**:
   Verify that the configuration is now valid by running the debug check again:
   ```bash
   logrotate -d /etc/logrotate.d/noisy-app
   ```
   It should output the planned rotation steps without configuration errors.
   
   Force run logrotate to rotate the logs:
   ```bash
   sudo logrotate -f /etc/logrotate.d/noisy-app
   ```

4. **Verify the Output Files**:
   List `/var/log/` to ensure the rotated file was created:
   ```bash
   ls -la /var/log/noisy-app*
   ```
   You should see `/var/log/noisy-app.log.1` (or a compressed version `/var/log/noisy-app.log.1.gz` if compress is enabled and has run).
