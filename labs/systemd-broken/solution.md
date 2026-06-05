### The Issue

The systemd unit file for the `demo` service (`/etc/systemd/system/demo.service`) has a misconfigured `ExecStart` path. It points to a non-existent file `/usr/local/bin/demo-service.sh` instead of the actual script located at `/usr/local/bin/demo.sh`.

### Step-by-Step Fix

1. **Diagnose the service failure:**
   Run `systemctl status demo` to check the service status.
   ```bash
   sudo systemctl status demo
   ```
   You will see an error indicating that the executable could not be found (status `203/EXEC` or `No such file or directory`).

2. **Locate the script:**
   List the files in `/usr/local/bin` to find the actual script name:
   ```bash
   ls -la /usr/local/bin
   ```
   You will notice the script is named `demo.sh`.

3. **Edit the systemd service file:**
   Open the systemd unit file:
   ```bash
   sudo nano /etc/systemd/system/demo.service
   ```
   Modify the `ExecStart` line to point to `/usr/local/bin/demo.sh`:
   ```text
   ExecStart=/usr/local/bin/demo.sh
   ```

4. **Reload systemd, reset failed state, and start the service:**
   Any time you modify a systemd service file, you must reload the systemd manager configuration. Since the service repeatedly failed during boot, it may have hit systemd's start limit rate-limiting. Reset the failed status before starting the service:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl reset-failed demo
   sudo systemctl start demo
   ```

5. **Ensure it is enabled on boot:**
   Enable the service so it starts automatically next time the system boots:
   ```bash
   sudo systemctl enable demo
   ```

6. **Verify:**
   Confirm the service is running and active:
   ```bash
   sudo systemctl status demo
   ```
