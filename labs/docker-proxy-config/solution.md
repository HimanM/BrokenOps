### The Issue
The Docker daemon does not automatically use the environment variables (like `HTTP_PROXY`) set in your user shell. It must be explicitly configured via a systemd drop-in file or the `daemon.json` configuration to know which proxy to use for outbound requests, such as pulling images from Docker Hub.

### Step-by-Step Fix

1. **Verify the failure**:
   ```bash
   docker pull alpine
   ```
   The command will likely time out or return an error related to "no such host" or "connection refused".

2. **Create a systemd drop-in directory for Docker**:
   ```bash
   sudo mkdir -p /etc/systemd/system/docker.service.d
   ```

3. **Create the proxy configuration file**:
   Create a file named `/etc/systemd/system/docker.service.d/http-proxy.conf`.
   ```ini
   [Service]
   Environment="HTTP_PROXY=http://127.0.0.1:3128"
   Environment="HTTPS_PROXY=http://127.0.0.1:3128"
   Environment="NO_PROXY=localhost,127.0.0.1"
   ```
   *(Note: In this lab, the proxy is running locally on port 3128).*

4. **Reload systemd daemon**:
   ```bash
   sudo systemctl daemon-reload
   ```

5. **Restart Docker**:
   ```bash
   sudo systemctl restart docker
   ```

6. **Verify the fix**:
   ```bash
   docker pull alpine
   ```
   The pull should now succeed.
