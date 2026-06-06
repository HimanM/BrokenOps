### The Issue

Nginx is failing to start because it is configured to bind to a non-standard port (`8080`), which is blocked by the active SELinux policy. 

Under SELinux, network services are only allowed to bind to port numbers defined in their respective policy contexts. By default, the HTTP service (`http_port_t`) is only permitted to bind to standard web ports (like `80`, `443`, `81`, etc.). Binding to other ports (like `8080`) is denied, and the attempt is logged as an AVC (Access Vector Cache) denial in `/var/log/audit/audit.log`.

### Step-by-Step Fix

1. **Diagnose the failure**:
   Check the status of the Nginx service:
   ```bash
   sudo systemctl status nginx
   ```
   You will see a bind permission error.
   
   Check the audit log to locate the SELinux AVC denial:
   ```bash
   sudo tail -n 50 /var/log/audit/audit.log | grep AVC
   ```
   Or check system logs:
   ```bash
   sudo journalctl -xeu nginx
   ```
   You will find a line indicating `denied { name_bind }` for `port 8080` under the `httpd_t` domain.

2. **Verify the allowed HTTP ports**:
   Use `semanage` to list the ports currently allowed for the `http_port_t` context:
   ```bash
   sudo semanage port -l | grep http_port_t
   ```
   You will see that `8080` is not listed.

3. **Map the custom port to http_port_t**:
   Add port `8080` to the allowed ports for the HTTP service:
   ```bash
   sudo semanage port -a -t http_port_t -p tcp 8080
   ```

4. **Restart Nginx**:
   Restart the service so that it successfully binds to port `8080`:
   ```bash
   sudo systemctl restart nginx
   ```

5. **Verify connectivity**:
   Test that Nginx is running and serving traffic on port 8080:
   ```bash
   curl -I http://localhost:8080
   ```
