### The Issue

The filesystem mounted at `/data` has run out of space because the Logical Volume (`/dev/vg_data/lv_data`) was originally provisioned with a size of only 500 MB. 

However, the Volume Group (`vg_data`) has about 1.5 GB of free space that is currently unallocated. The volume size can be expanded online, and the `ext4` filesystem can be resized dynamically to absorb the new space without interrupting any database services.

### Step-by-Step Fix

1. **Verify disk space and LVM status**:
   Run `df` to check disk usage:
   ```bash
   df -h /data
   ```
   You will see that `/data` is 100% full.
   
   Run `vgs` to verify if there is free space in the volume group:
   ```bash
   sudo vgs
   ```
   You should see that `vg_data` has around `1.50g` of free space (`VFree` column).

2. **Extend the logical volume**:
   Extend the logical volume `lv_data` to utilize 100% of the free space available in the volume group `vg_data`:
   ```bash
   sudo lvextend -l +100%FREE /dev/vg_data/lv_data
   ```

3. **Resize the filesystem**:
   Resize the `ext4` filesystem online so that it expands to fill the newly enlarged logical volume:
   ```bash
   sudo resize2fs /dev/vg_data/lv_data
   ```

4. **Verify the results**:
   Check the disk space again to ensure the capacity has increased and there is free space:
   ```bash
   df -h /data
   ```
   The size should now be approximately 2.0 GB, with plenty of free space.
