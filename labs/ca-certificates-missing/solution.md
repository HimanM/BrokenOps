### The Issue

The machine has the local CA certificate file on disk, but the system trust store was never refreshed. As a result, HTTPS downloads from the local server fail verification and the bootstrap package cannot be installed.

### Step-by-Step Fix

1. **Refresh the CA trust store**:
   ```bash
   sudo update-ca-certificates
   ```
2. **Restart the bootstrap service**:
   ```bash
   sudo systemctl restart lab-bootstrap.service
   ```
3. **Verify the package was installed**:
   ```bash
   dpkg -s labtool
   ```
4. **Confirm HTTPS downloads now work**:
   ```bash
   curl -fsS https://localhost:8443/labtool_1.0_all.deb -o /tmp/labtool.deb
   ```
