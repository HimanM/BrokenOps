### Scenario

A system administrator set up a 512MB swap file at `/swapfile` to mitigate memory exhaustion during high load. They activated the swap, but after the server was rebooted for kernel updates, the swap space disappeared. 

Troubleshoot the system and configure the swap file so that it is active and persists across system restarts.

### Objective

1. Verify that the swap file `/swapfile` exists on disk but is not currently active.
2. Configure the swap space persistently so that it automatically mounts during system boot.
3. Make sure the swap is active and correctly configured.

### Useful Commands

- `swapon --show`
- `free -h`
- `cat /etc/fstab`
