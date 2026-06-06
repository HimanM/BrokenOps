### The Issue

The backup destination file `/var/backups/app/latest.tar.gz` has the **immutable** attribute (`+i`) set. In Linux, files with the immutable attribute cannot be modified, deleted, renamed, or written to, even by the `root` user. This causes the backup script to fail with an "Operation not permitted" error.

### Step-by-Step Fix

1. **Observe the failure**:
   Run the backup script manually and notice the write error:
   ```bash
   /usr/local/bin/backup.sh
   ```

2. **Inspect file attributes**:
   Standard file permissions (visible via `ls -l`) might appear normal. Instead, check the extended filesystem attributes using `lsattr`:
   ```bash
   lsattr /var/backups/app/latest.tar.gz
   ```
   You should see the letter `i` listed in the output attributes, representing the immutable flag.

3. **Remove the immutable attribute**:
   Use the `chattr` command to remove the immutable attribute from the file:
   ```bash
   sudo chattr -i /var/backups/app/latest.tar.gz
   ```

4. **Verify the fix**:
   Confirm the attribute is removed by running `lsattr` again, then run the backup script to ensure it succeeds:
   ```bash
   lsattr /var/backups/app/latest.tar.gz
   /usr/local/bin/backup.sh
   ```
