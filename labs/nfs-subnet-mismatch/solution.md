### The Issue
The NFS export configuration in `/etc/exports` was restricted to a subnet (`192.0.2.0/24`) that did not include the client's network. NFS uses this file to determine which hosts or subnets are authorized to mount specific directories.

### Step-by-Step Fix

1. **Verify the error**:
   Try mounting the share locally to confirm the issue.
   ```bash
   sudo mkdir -p /mnt/test
   sudo mount -t nfs $(hostname -I | awk '{print $1}'):/srv/nfs/shared /mnt/test
   ```
   You will likely see `mount.nfs: access denied by server while mounting`.

2. **Check exports**:
   Use `exportfs` to see what is currently being exported and to whom.
   ```bash
   sudo exportfs -v
   ```
   You will see `/srv/nfs/shared 192.0.2.0/24(...)`.

3. **Identify your IP/Subnet**:
   Check your own IP address to see if it matches the exported subnet.
   ```bash
   hostname -I
   ```

4. **Correct the export configuration**:
   Edit `/etc/exports` and update the allowed subnet to match your network, or use `*` to allow all (depending on security requirements).
   ```bash
   sudo vi /etc/exports
   ```
   Change:
   `/srv/nfs/shared 192.0.2.0/24(...)`
   To:
   `/srv/nfs/shared *(rw,sync,no_subtree_check)`

5. **Apply changes**:
   Reload the export table.
   ```bash
   sudo exportfs -ra
   ```

6. **Verify**:
   Try the mount command again. It should now succeed.
   ```bash
   sudo mount -t nfs $(hostname -I | awk '{print $1}'):/srv/nfs/shared /mnt/test
   ```
