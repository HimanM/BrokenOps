### Scenario
A web application running as the `webapp` user is failing to write its logs to `/var/log/webapp`. The systems administrator checked the directory permissions using `ls -ld /var/log/webapp` and they appear to be correct (`drwxrwxr-x`), with the group set to `webapp`. However, the application still receives "Permission denied" errors.
### Objective
Identify why the `webapp` user cannot write to `/var/log/webapp` despite the standard permissions, and fix the issue.
### Useful Commands
- `ls -ld /var/log/webapp`
- `getfacl /var/log/webapp`
- `setfacl`
- `sudo -u webapp touch /var/log/webapp/test`
