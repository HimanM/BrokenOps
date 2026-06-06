### Scenario
A critical database application has stopped working because its data directory, `/data`, has run out of space (100% disk usage).

The storage engineer informs you that this directory is mounted on an LVM Logical Volume (`lv_data`) inside a Volume Group (`vg_data`), and there are still free extents available in the Volume Group. You must investigate the LVM configuration and resize the logical volume and filesystem online to get the database back up and running.

### Objective
Extend the Logical Volume and filesystem mounted at `/data` so that:
1. The filesystem capacity is expanded to at least 1.2 GB.
2. The filesystem has at least 500 MB of free space.
3. The expansion is done online (without unmounting or rebooting).

### Useful Commands
- `df`
- `vgs`
- `lvs`
- `lvextend`
- `resize2fs`
