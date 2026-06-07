### The Issue
The slow SSH login was caused by the `UseDNS yes` setting in `/etc/ssh/sshd_config` combined with an unreachable DNS server. When `UseDNS` is enabled, the SSH daemon attempts to perform a reverse DNS lookup on the client's IP address. If the DNS server is unresponsive, the lookup must time out before the login process can continue.

### Step-by-Step Fix

1. **Check SSH configuration**:
   Look for settings that might cause delays, such as DNS lookups or GSSAPI authentication.
   ```bash
   grep UseDNS /etc/ssh/sshd_config
   ```

2. **Diagnose DNS issues**:
   Check if the system's resolver is healthy.
   ```bash
   resolvectl status
   ```
   If it points to an unreachable IP, lookups will be slow.

3. **Disable UseDNS**:
   The most robust fix for SSH slowness in many environments is to disable reverse DNS lookups in the SSH daemon.
   ```bash
   sudo sed -i 's/UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
   # If it doesn't exist, add it:
   echo "UseDNS no" | sudo tee -a /etc/ssh/sshd_config
   ```

4. **Restart SSH**:
   ```bash
   sudo systemctl restart ssh
   ```

5. **Fix the resolver (optional but recommended)**:
   Remove any broken DNS configuration.
   ```bash
   sudo rm /etc/systemd/resolved.conf.d/broken-dns.conf
   sudo systemctl restart systemd-resolved
   ```

6. **Verify**:
   Log out and log back in (or simulate a connection) to confirm the prompt appears immediately.
