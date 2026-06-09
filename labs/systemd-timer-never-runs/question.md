### Scenario

A backup job named `nightly-backup` should run shortly after boot and then repeat every minute. After a reboot, the job never runs and the expected log file is never created.

Investigate the timer and service configuration, fix the boot-time activation problem, and make sure the backup job runs successfully.

### Objective

1. Inspect the systemd timer and service unit files.
2. Find why the timer is not being activated on a normal boot.
3. Fix the broken timer installation target and enable the timer.
4. Confirm the backup job runs and writes to its log file.

### Useful Commands

- `systemctl status nightly-backup.timer`
- `systemctl list-timers --all`
- `systemctl cat nightly-backup.timer`
- `journalctl -u nightly-backup.service`
