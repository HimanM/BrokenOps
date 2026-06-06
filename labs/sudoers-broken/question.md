### Scenario

A junior sysadmin tried to configure passwordless sudo privileges for the `ops` user. They created a new drop-in file in `/etc/sudoers.d/ops`, but made a syntax error in the rule. Because of this error, `sudo` is now broken for all users, printing syntax and configuration errors.

### Objective

Your task is to:
1. Identify the syntax error in the `/etc/sudoers.d/` drop-in files.
2. Correct the drop-in file so that the `ops` user has valid, passwordless sudo privileges (`NOPASSWD: ALL`).
3. Verify that the sudo configuration passes validation checks.

### Useful Commands

- `sudo -l`
- `visudo -c`
- `cat /etc/sudoers.d/ops`
