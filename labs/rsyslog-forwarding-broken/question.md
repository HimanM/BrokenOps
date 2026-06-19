### Scenario

Local logs are written normally, but they never reach the central collector. The collector service is up, yet forwarded syslog messages are missing.

Fix the forwarding rule so the remote collector receives the logs again.

### Objective

1. Inspect the rsyslog forwarding configuration.
2. Identify why messages are not reaching the collector.
3. Fix the forwarding protocol or endpoint and confirm receipt on the collector.
4. Verify rsyslog remains healthy after the change.

### Useful Commands

- `systemctl status rsyslog`
- `rsyslogd -N1`
- `cat /etc/rsyslog.d/50-forward.conf`
- `logger -t brokenops-rsyslog "test message"`
