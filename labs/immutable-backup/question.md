### Scenario

The system's automated application backup script `/usr/local/bin/backup.sh` is failing with write errors. It is supposed to write or overwrite `/var/backups/app/latest.tar.gz`, but even running the script as the `root` user results in a "Permission denied" or "Operation not permitted" error.

Find out why the destination file cannot be modified and fix the issue so the backup script completes successfully.

### Objective

Your task is to:
1. Diagnose why `/usr/local/bin/backup.sh` cannot write or overwrite `/var/backups/app/latest.tar.gz`.
2. Remove any attribute or configuration blocking modification of `/var/backups/app/latest.tar.gz`.
3. Verify that `/usr/local/bin/backup.sh` executes successfully.

### Useful Commands

- `/usr/local/bin/backup.sh`
- `ls -l /var/backups/app/latest.tar.gz`
- `lsattr /var/backups/app/latest.tar.gz`
- `chattr`
