### Scenario

A system administrator configured a cron job to run a cleanup script `/opt/cleanup.sh` every minute. However, the cleanup log `/var/log/cleanup.log` is never created, and the script does not seem to execute.

Troubleshoot the system, locate the issues preventing the script from running, and fix them so the cron job runs successfully.

### Objective

1. Locate the scheduled cron job configuration under `/etc/cron.d/` and find the target script `/opt/cleanup.sh`.
2. Diagnose why the script cannot be executed by the cron daemon.
3. Fix the script's shebang (interpreter directive) and file permissions.
4. Ensure the cron service is running and the script executes correctly.

### Useful Commands

- `cat /etc/cron.d/cleanup`
- `ls -l /opt/cleanup.sh`
- `head -n 1 /opt/cleanup.sh`
- `sudo tail -f /var/log/syslog | grep cron`
