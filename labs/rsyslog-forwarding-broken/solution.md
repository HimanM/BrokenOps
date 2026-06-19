### The Issue

The forwarding rule used the wrong transport. The collector listens on TCP, but the rsyslog rule was sending UDP packets, so the messages never arrived.

### Step-by-Step Fix

1. **Inspect the forwarding rule**:
   ```bash
   cat /etc/rsyslog.d/50-forward.conf
   ```
   You should see a single `@` in the forwarding target.

2. **Validate the configuration**:
   ```bash
   sudo rsyslogd -N1
   ```
   That confirms the syntax is valid, but it does not guarantee the collector will receive the message.

3. **Switch the rule to TCP forwarding**:
   Change the rule to use a double `@@`:
   ```bash
   sudo sh -c 'printf "*.* @@127.0.0.1:1514\n" > /etc/rsyslog.d/50-forward.conf'
   sudo systemctl restart rsyslog
   ```

4. **Send a test log message**:
   ```bash
   logger -t brokenops-rsyslog "rsyslog forwarding test"
   tail -n 20 /var/log/collector.log
   ```
   Once the transport matches the collector, the message shows up in the log file.
