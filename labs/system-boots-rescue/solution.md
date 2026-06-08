### The Issue
The system's default boot target was incorrectly set to `rescue.target`. Systemd uses the default target to determine which services and environment to load upon startup. `rescue.target` is intended for administrative repairs and only starts a minimal set of services.

### Step-by-Step Fix

1. **Verify the current default target**:
   Check what target the system is configured to boot into by default.
   ```bash
   systemctl get-default
   ```
   You will see `rescue.target`.

2. **Change the default target**:
   Set the default target back to `multi-user.target`, which is the standard mode for servers.
   ```bash
   sudo systemctl set-default multi-user.target
   ```

3. **Verify the change**:
   ```bash
   systemctl get-default
   ```
   It should now return `multi-user.target`.

4. **Reboot (Optional but recommended in real life)**:
   In a real scenario, you would reboot to ensure the system starts all services correctly.
   ```bash
   sudo reboot
   ```
