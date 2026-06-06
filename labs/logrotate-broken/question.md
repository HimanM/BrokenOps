### Scenario
A production logging application writes diagnostic logs to `/var/log/noisy-app.log`. An operations engineer deployed a custom logrotate configuration to prevent the logs from consuming all disk space. 

However, users have noticed that the log file continues to grow indefinitely, and log rotation is not occurring.

### Objective
Diagnose and repair the logrotate configuration so that `/var/log/noisy-app.log` successfully rotates. Running `logrotate -f /etc/logrotate.d/noisy-app` should run cleanly and successfully rotate the log files.

### Useful Commands
- `logrotate -d /etc/logrotate.d/noisy-app`
- `logrotate -f /etc/logrotate.d/noisy-app`
- `ls -la /var/log/noisy-app*`
- `cat /etc/logrotate.d/noisy-app`
