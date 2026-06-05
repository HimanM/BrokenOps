### The Issue

`/etc/resolv.conf` was rewritten to use `nameserver 127.0.0.99`, which is not a valid DNS resolver on this machine. As a result, hostname lookups fail even though network connectivity to IP addresses still works.

### Step-by-Step Fix

1. **Reproduce the symptom**:
   ```bash
   ping -c 2 google.com
   ping -c 2 8.8.8.8
   ```
   The first should fail to resolve, while the second should succeed.

2. **Inspect resolver configuration**:
   ```bash
   cat /etc/resolv.conf
   ```
   You should see an invalid resolver like `127.0.0.99`.

3. **Replace with a valid resolver**:
   ```bash
   sudo tee /etc/resolv.conf >/dev/null <<'EOF'
   nameserver 8.8.8.8
   EOF
   ```

4. **Verify DNS works again**:
   ```bash
   getent hosts google.com
   ping -c 2 google.com
   ```
