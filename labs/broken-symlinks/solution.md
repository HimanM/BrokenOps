### The Issue
During a messy file migration, the original target files for the application were moved to `/opt/app/new_location/`, but the links pointing to them were not properly updated.
- The soft link `/opt/app/config/current_config` was left pointing to a non-existent path (`/opt/app/old_location/app_config`).
- The hard link `/opt/app/data/current_db` was left pointing to an old inode containing incorrect data.

### Step-by-Step Fix

1. **Verify the error**:
   Run the application script to see the failure.
   ```bash
   /opt/app/bin/run.sh
   ```
   It will output an error about the config or db data.

2. **Inspect the soft link**:
   Check where the config link is pointing.
   ```bash
   ls -l /opt/app/config/current_config
   ```
   You will see it points to a path that does not exist (usually highlighted in red in the terminal).

3. **Fix the soft link**:
   Remove the broken link and create a new one pointing to the correct file in the new location.
   ```bash
   sudo rm /opt/app/config/current_config
   sudo ln -s /opt/app/new_location/app_config /opt/app/config/current_config
   ```

4. **Inspect the hard link**:
   Check the data file.
   ```bash
   cat /opt/app/data/current_db
   ```
   It contains `wrong_data` instead of the expected database content.

5. **Fix the hard link**:
   Remove the incorrect hard link and create a new hard link pointing to the correct file.
   ```bash
   sudo rm /opt/app/data/current_db
   sudo ln /opt/app/new_location/app_db /opt/app/data/current_db
   ```

6. **Verify the fix**:
   Run the application script again.
   ```bash
   /opt/app/bin/run.sh
   ```
   It should now output `Application running successfully`.
