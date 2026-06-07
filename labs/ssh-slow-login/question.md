### Scenario
Administrators are reporting that connecting to this server via SSH takes a very long time (sometimes up to 30 seconds) before the password prompt appears. Once logged in, the system seems to perform normally, but the initial connection delay is unacceptable.

### Objective
Diagnose the cause of the SSH login delay and fix it so that logins are nearly instantaneous.

### Useful Commands
- `ssh -v [user]@[host]` (Run this from a client, or imagine the output)
- `grep -r "UseDNS" /etc/ssh/`
- `resolvectl status`
- `journalctl -u ssh`
