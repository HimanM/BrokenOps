### The Issue

The `/shared/tmp` directory was configured with `0777` (`drwxrwxrwx`) permissions. While this allows all users to read, write, and execute files, the absence of the **sticky bit** allows any user to delete or rename files in the directory regardless of who owns them.

### Step-by-Step Fix

1. **Inspect current permissions**:
   Check the current mode of the `/shared/tmp` directory:
   ```bash
   ls -ld /shared/tmp
   ```
   You should see `drwxrwxrwx`, showing that the sticky bit (`t`) is missing at the end of the permissions block.

2. **Apply the sticky bit**:
   To restrict file deletion/renaming to the file's owner, add the sticky bit to the directory:
   ```bash
   sudo chmod +t /shared/tmp
   ```
   Alternatively, you can set it explicitly via octal permissions:
   ```bash
   sudo chmod 1777 /shared/tmp
   ```

3. **Verify the change**:
   Verify that the sticky bit is active:
   ```bash
   ls -ld /shared/tmp
   ```
   The output should now show `drwxrwxrwt`.
