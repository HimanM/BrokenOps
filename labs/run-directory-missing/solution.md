### The Issue

The service writes a PID file into `/run/demo-app`, but the unit file never asks systemd to create that runtime directory. As a result, the app fails before it can bind to its port.

### Step-by-Step Fix

1. **Tell systemd to create the runtime directory**:
   ```bash
   sudo sed -i '/^Restart=on-failure$/a RuntimeDirectory=demo-app
RuntimeDirectoryMode=0755' /etc/systemd/system/demo-app.service
   ```
2. **Reload systemd and restart the service**:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl restart demo-app.service
   ```
3. **Verify the app is running**:
   ```bash
   curl -fsS http://127.0.0.1:4000/
   ```
