### Scenario

A maintenance job is supposed to run automatically through a systemd timer, but after reboot it never fires. The service exists and works, yet the timer was never enabled to start on boot.

### Objective

1. Inspect the timer and service units.
2. Determine why the maintenance job does not run after reboot.
3. Enable the timer so systemd starts it automatically.
4. Confirm the timer is active and the job has written its heartbeat file.

### Useful Commands

- `systemctl status cleanup-note.timer`
- `systemctl cat cleanup-note.timer`
- `systemctl list-timers`
- `cat /var/lib/brokenops/cleanup.log`
