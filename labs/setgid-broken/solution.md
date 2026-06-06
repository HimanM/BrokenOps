### The Issue

The shared directory `/var/shared/project` is missing the `setgid` (set group ID) permission bit.

By default, when a user creates a file in Linux, the file's group owner is set to the user's primary group (e.g., `alice` or `bob`). In a collaborative directory, this causes permission issues because other members of the `devs` group won't have write access.

By enabling the `setgid` bit on the directory, any new files or subdirectories created within it will automatically inherit the directory's group owner (`devs`) rather than the creator's primary group.

### Step-by-Step Fix

1. **Verify the current permissions and ownership**:
   Inspect the directory's group ownership and special permissions:
   ```bash
   ls -ld /var/shared/project
   ```
   You will notice the directory is owned by group `devs` and has permissions `rwxrwx---`, but the `setgid` bit (indicated by an `s` in the group execute position, e.g. `rwxrws---`) is missing.

2. **Fix group ownership recursively**:
   Ensure all existing files and folders within `/var/shared/project` belong to the `devs` group:
   ```bash
   sudo chgrp -R devs /var/shared/project
   ```

3. **Enable the setgid bit on the directory**:
   Apply the `setgid` bit to the directory:
   ```bash
   sudo chmod g+s /var/shared/project
   ```

4. **Ensure appropriate read/write permissions**:
   Ensure all group members can read and write to files and traverse directories recursively:
   ```bash
   sudo chmod -R g+rw /var/shared/project
   sudo find /var/shared/project -type d -exec sudo chmod g+x {} +
   ```

5. **Verify the fix**:
   Create a new file inside the directory and check its group ownership:
   ```bash
   touch /var/shared/project/test.txt
   ls -l /var/shared/project/test.txt
   ```
   The group ownership of `test.txt` should be `devs`.
