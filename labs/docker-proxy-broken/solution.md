### The Issue

Docker daemon traffic is restricted to localhost in this lab to simulate a corporate network path. A local proxy (`tinyproxy`) is available, but Docker does not use it by default. Without daemon proxy environment variables, image pulls time out.

### Step-by-Step Fix

1. **Create Docker proxy drop-in directory**:
   ```bash
   sudo mkdir -p /etc/systemd/system/docker.service.d
   ```

2. **Add proxy environment variables for the Docker daemon**:
   ```bash
   sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf >/dev/null <<'EOF'
   [Service]
   Environment="HTTP_PROXY=http://127.0.0.1:8888"
   Environment="HTTPS_PROXY=http://127.0.0.1:8888"
   Environment="NO_PROXY=localhost,127.0.0.1"
   EOF
   ```

3. **Reload systemd and restart Docker**:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl restart docker
   ```

4. **Verify Docker now has proxy environment settings**:
   ```bash
   systemctl show docker --property=Environment
   ```

5. **Confirm image pull succeeds**:
   ```bash
   docker pull hello-world
   ```
