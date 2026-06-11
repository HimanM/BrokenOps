### The Issue
The service writes a PID file into `/run/demo-app`, but the systemd unit never tells systemd to create that runtime directory. On top of that, the application is only listening on `127.0.0.1`, so the browser proxy cannot reach it even after the service starts.

### Step-by-Step Fix

1. **Inspect the unit and confirm the missing runtime directory**:
   Read the service definition first so you can see what systemd is actually managing.
   ```bash
   systemctl cat demo-app.service
   ```

2. **Edit the service file by hand**:
   Add the runtime directory directives to the unit so systemd creates `/run/demo-app` before the service starts.
   - `RuntimeDirectory=demo-app`
   - `RuntimeDirectoryMode=0755`

3. **Fix the application bind address**:
   Update the launch script or service command so the app listens on `0.0.0.0` instead of `127.0.0.1`.
   - If the script is shell-based, change the bind flag in the command.
   - If the bind address lives in an environment file, update it there instead.

4. **Reload systemd and restart the service**:
   Once the unit file and bind address are corrected, reload the manager and restart the service.
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl restart demo-app.service
   ```

5. **Verify locally and through the lab proxy**:
   Confirm the app responds on the VM and then through the exposed port path.
   ```bash
   curl -fsS http://127.0.0.1:4000/
   ```
