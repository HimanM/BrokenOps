### Scenario

You have been handed a server where a custom background service named `demo` is supposed to run automatically and log data to `/var/log/demo.log`. However, the service is currently inactive and fails to start.

Find out why the service is failing, fix the configuration, and ensure the service starts successfully and remains enabled on boot.

### Objective

1. Check the status of the `demo` service and diagnose why it fails to start.
2. Locate the service unit file and fix the invalid executable path.
3. Reload systemd, enable the service, and verify that the service is running successfully.

### Useful Commands

- `sudo systemctl status demo`
- `sudo journalctl -u demo`
- `sudo systemctl daemon-reload`
