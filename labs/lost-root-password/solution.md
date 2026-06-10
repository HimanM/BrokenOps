### The Issue
The `opsuser` user was stripped of all sudo privileges and the root password was changed to an unknown value. However, the server was left with a dangerous sudo misconfiguration: `opsuser` is allowed to run `/usr/bin/find` as root without a password. Since the `find` command supports the `-exec` flag, this can be exploited to spawn an interactive root shell.

### Step-by-Step Fix

1. **Enumerate sudo privileges**:
   ```bash
   sudo -l
   ```
   You will see that `opsuser` may run `/usr/bin/find` as root without a password.

2. **Exploit `find` to get a root shell**:
   ```bash
   sudo find / -exec /bin/bash \;
   ```
   You are now running as root (UID 0).

3. **Restore opsuser to the sudo group**:
   ```bash
   usermod -aG sudo opsuser
   ```

4. **Clean up the dangerous sudo rule**:
   ```bash
   sed -i "/opsuser ALL=(root) NOPASSWD: \/usr\/bin\/find/d" /etc/sudoers
   ```

5. **Reset the root password**:
   ```bash
   echo "root:BrokenOps123" | chpasswd
   ```

6. **Verify**:
   ```bash
   visudo -c
   groups opsuser
   ```