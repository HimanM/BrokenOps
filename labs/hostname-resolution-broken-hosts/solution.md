### The Issue
`/etc/hosts` only contained the fully qualified entry for `api-server.internal.brokenops.io`. The short name `api-server` was missing, so resolver lookups for the abbreviated hostname failed.

### Step-by-Step Fix

1. **Inspect `/etc/hosts`**:
   Confirm the host file only maps the FQDN.
   ```bash
   cat /etc/hosts
   ```

2. **Add the short alias**:
   Update the mapping so the short name and FQDN both point to `10.0.0.50`.
   ```bash
   echo '10.0.0.50 api-server api-server.internal.brokenops.io' >> /etc/hosts
   ```

3. **Verify resolution**:
   Check that the short hostname now resolves correctly.
   ```bash
   getent hosts api-server
   ```

4. **Outcome**:
   Once the alias is present, local applications can resolve `api-server` again.
