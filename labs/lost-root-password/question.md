### Scenario
A new sysadmin changed the root password on this server and forgot it. You have been given SSH access as the `opsuser` user, but `opsuser` does not have `sudo` privileges. Attempting to run any command with `sudo` results in a permission denial.

You need to regain root access and restore the system to a healthy state.

### Objective
1. Find a way to escalate privileges from the `opsuser` account to root.
2. Restore normal sudo access for `opsuser`.
3. Reset the root password to a known value.

### Useful Commands
- `sudo -l`
- `groups opsuser`
- `sudo find / -exec /bin/bash \;`
- `usermod -aG sudo opsuser`
- `echo "root:PASSWORD" | chpasswd`
- `visudo -c`