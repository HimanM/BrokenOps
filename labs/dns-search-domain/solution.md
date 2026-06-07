### The Issue
The issue is a missing or incorrect DNS search domain. While the FQDN (`api-server.internal.brokenops.io`) resolves correctly because it's a complete record, the short name (`api-server`) relies on the system appending the correct search domain (e.g., `internal.brokenops.io`) to create an FQDN that the resolver can find.

### Step-by-Step Fix

1. **Verify the problem**:
   Attempt to ping both the FQDN and the short name.
   ```bash
   ping -c 1 api-server.internal.brokenops.io # Should succeed
   ping -c 1 api-server                     # Should fail
   ```

2. **Check resolver status**:
   Use `resolvectl status` to see the current DNS settings, including search domains.
   ```bash
   resolvectl status
   ```
   You will likely see an incorrect domain listed under "DNS Domain" or "DNS Search Domains".

3. **Identify the missing domain**:
   Since the FQDN ends in `internal.brokenops.io`, this is the domain that needs to be in the search path.

4. **Correct the configuration**:
   On systems using `systemd-resolved`, you can add a configuration drop-in.
   ```bash
   sudo mkdir -p /etc/systemd/resolved.conf.d
   echo -e "[Resolve]\nDomains=internal.brokenops.io" | sudo tee /etc/systemd/resolved.conf.d/search.conf
   ```

5. **Restart the resolver**:
   ```bash
   sudo systemctl restart systemd-resolved
   ```

6. **Verify the fix**:
   ```bash
   getent hosts api-server
   ping -c 1 api-server
   ```
