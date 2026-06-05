### The Issue

The `web-app` container is configured with a healthcheck command:
`curl -f http://localhost/ || kill 1`

Since `curl` is not installed in the lightweight `nginx:alpine` image, the healthcheck command fails. The `|| kill 1` part of the command then executes, sending a termination signal to PID 1 inside the container, killing it. The systemd service restarts the container, causing a continuous crash/restart loop.

### Step-by-Step Fix

1. **Check container status and logs:**
   Use `docker ps` to see the container status. You will notice the container status alternates between `Starting` and `Up 1 second` with the restart count increasing.
   ```bash
   docker ps
   ```

2. **Inspect the healthcheck configuration:**
   Inspect the container configuration to see the healthcheck command:
   ```bash
   docker inspect web-app | grep -A 5 Healthcheck
   ```
   You will see:
   `"Test": [ "CMD-SHELL", "curl -f http://localhost/ || kill 1" ]`

3. **Locate and edit the service file:**
   The container is managed by systemd. Open the service definition file:
   ```bash
   sudo nano /etc/systemd/system/web-app.service
   ```
   Modify the `ExecStart` line to use a valid healthcheck command (such as `wget` which is built into Alpine, or simply remove the `|| kill 1` trigger):
   ```text
   ExecStart=/usr/bin/docker run --name web-app --health-cmd "wget -qO- http://localhost/ || exit 1" --health-interval 5s --health-timeout 2s --health-retries 1 -p 80:80 nginx:alpine
   ```

4. **Reload systemd and restart the service:**
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl restart web-app
   ```

5. **Verify the container is healthy:**
   ```bash
   docker ps
   ```
   Wait a few seconds and check again. The status should be `Up ... (healthy)`.
