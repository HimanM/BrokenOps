### The Issue

A swap file needs to be manually added to `/etc/fstab` for it to persist across system reboots. If you only activate it using `swapon /swapfile`, it will work temporarily but will be lost once the machine is restarted.

### Step-by-Step Fix

1. **Check current swap usage:**
   Run `free -h` or `swapon --show` to see if there is any active swap.
   ```bash
   swapon --show
   ```
   You will notice that no swap file is active, even though `/swapfile` exists on the disk.

2. **Activate the swap file immediately:**
   Enable the swap file using the `swapon` command:
   ```bash
   sudo swapon /swapfile
   ```

3. **Make the swap file persistent:**
   To make it persist across system reboots, you need to add an entry for it in `/etc/fstab`. Open `/etc/fstab` using a text editor (like `nano` or `vi`) and append the following line:
   ```text
   /swapfile none swap sw 0 0
   ```
   Or use `echo` to append it directly:
   ```bash
   echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
   ```

4. **Verify the configuration:**
   Verify that swap is active:
   ```bash
   swapon --show
   ```
