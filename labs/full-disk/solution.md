### The Issue

When a system is completely out of disk space, it can cause services to crash, databases to corrupt, and prevent users from logging in. In this case, a massive rogue file is filling up the `/var/log` directory.

### Step-by-Step Fix

1. **Verify the filesystem usage:**
   Run the `df` command to see mounted filesystems and their usage.
   ```bash
   df -h
   ```
   You will notice that the root filesystem `/` is at 100% capacity.

2. **Locate the large files:**
   Since you know the disk is full, you need to find out what is taking up so much space. A good starting point is the `/var/log` directory. You can use `du` (disk usage) to find the culprits:
   ```bash
   sudo du -ah /var/log | sort -rh | head -n 10
   ```
   Alternatively, you can use the `find` command to search the entire filesystem for files larger than 1GB:
   ```bash
   sudo find / -type f -size +1G
   ```
   This will reveal a file named `massive_rogue.log`.

3. **Delete the file:**
   Once you have identified the file, remove it to instantly free up space:
   ```bash
   sudo rm /var/log/massive_rogue.log
   ```

4. **Verify the fix:**
   Run `df -h` again to ensure the disk space has dropped back to a normal level.
