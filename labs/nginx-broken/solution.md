### The Issue

Nginx was moved to TCP port `8080`, but SELinux policy did not allow HTTP services on that port.
So nginx fails to bind when SELinux is enforcing.

### Step-by-Step Fix

1. **Check nginx status and logs:**
   ```bash
   systemctl status nginx
   journalctl -xeu nginx.service
   ```

2. **Check SELinux denials:**
   ```bash
   ausearch -m avc -ts recent
   ```

3. **Confirm the custom port is not mapped to `http_port_t`:**
   ```bash
   semanage port -l | grep http_port_t
   ```

4. **Map TCP 8080 for HTTP services:**
   ```bash
   sudo semanage port -a -t http_port_t -p tcp 8080
   ```
   If it already exists with a different type, modify it instead:
   ```bash
   sudo semanage port -m -t http_port_t -p tcp 8080
   ```

5. **Restart nginx and verify:**
   ```bash
   sudo systemctl restart nginx
   ss -tuln | grep ':8080 '
   curl -I http://127.0.0.1:8080
   ```

You have solved the lab once nginx is reachable on port `8080` with SELinux still enforcing.
