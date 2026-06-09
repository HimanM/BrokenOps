### The Issue

The timer and service unit were present, but the timer was never enabled. Because of that, systemd did not add it to `timers.target`, so the boot-time job never ran.

### Step-by-Step Fix

1. **Reload the systemd configuration**:
   ```bash
   sudo systemctl daemon-reload
   ```

2. **Enable and start the timer**:
   ```bash
   sudo systemctl enable --now cleanup-note.timer
   ```

3. **Verify the timer is active**:
   ```bash
   systemctl list-timers cleanup-note.timer
   ```

4. **Confirm the maintenance task ran**:
   ```bash
   cat /var/lib/brokenops/cleanup-last-run
   cat /var/lib/brokenops/cleanup.log
   ```
