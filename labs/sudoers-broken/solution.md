### The Issue

A syntax error in the `/etc/sudoers.d/ops` file (e.g., `ALL_BROKEN_SYNTAX`) causes the sudo configuration parser to fail. Any attempt to use `sudo` will fail with syntax/parse errors, blocking administrative tasks.

### Step-by-Step Fix

1. **Verify the syntax error**:
   Check the sudoers configuration for syntax errors using `visudo -c`:
   ```bash
   visudo -c
   ```
   This will output a syntax error pointing to `/etc/sudoers.d/ops`.

2. **Fix the drop-in file**:
   Since you are logged in as `root` (or have direct root access to edit system files), you can edit the file. Run `visudo` targeting the drop-in file to correct the syntax safely:
   ```bash
   visudo -f /etc/sudoers.d/ops
   ```
   Modify the file to have correct syntax, granting the `ops` user passwordless sudo access:
   ```sudoers
   ops ALL=(ALL:ALL) NOPASSWD: ALL
   ```
   Or overwrite the file directly:
   ```bash
   echo "ops ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/ops
   chmod 0440 /etc/sudoers.d/ops
   ```

3. **Verify the syntax and sudo execution**:
   Run the verification tool again to ensure everything is correct:
   ```bash
   visudo -c
   ```
   Then verify the `ops` user can run commands via `sudo`:
   ```bash
   su - ops -c "sudo -n true"
   ```
