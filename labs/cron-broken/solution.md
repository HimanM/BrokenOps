### The Issue

For a script to be executed by the cron daemon, two conditions must be met:
1. **Executable Permissions**: The script file must have the execute permission bit set (e.g. `chmod +x`).
2. **Valid Interpreter (Shebang)**: The first line of the script (`#!...`) must specify a valid interpreter path (e.g., `#!/bin/bash` or `#!/bin/sh`). In this lab, it was set to `#!/bin/sh_invalid`.

### Step-by-Step Fix

1. **Locate the cron job configuration:**
   Inspect the custom cron configuration in `/etc/cron.d/`:
   ```bash
   cat /etc/cron.d/cleanup
   ```
   This tells you the cron job runs `/opt/cleanup.sh` as user `root` every minute.

2. **Inspect the cleanup script:**
   Check the file permissions and shebang of `/opt/cleanup.sh`:
   ```bash
   ls -l /opt/cleanup.sh
   head -n 1 /opt/cleanup.sh
   ```
   You will find that:
   - The file is not executable (permissions are `-rw-r--r--`).
   - The shebang is set to `#!/bin/sh_invalid` which is not a valid shell interpreter.

3. **Fix the shebang:**
   Open `/opt/cleanup.sh` in a text editor (like `nano` or `vi`) and change the first line to:
   ```bash
   #!/bin/bash
   ```

4. **Make the script executable:**
   Grant execute permission to `/opt/cleanup.sh`:
   ```bash
   sudo chmod +x /opt/cleanup.sh
   ```

5. **Verify the fix:**
   Run the script directly to make sure it executes without errors:
   ```bash
   sudo /opt/cleanup.sh
   ```
   Check if `/var/log/cleanup.log` was created. After a minute, the cron daemon should also start running it automatically.
