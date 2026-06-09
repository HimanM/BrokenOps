### Scenario

A web application is managed by systemd and should listen on port 4000. Instead, the service exits during startup because it tries to write a PID file into `/run/demo-app`, but that directory does not exist after boot.

Fix the service definition so systemd creates the runtime directory automatically and the application starts normally.

### Objective

1. Inspect the service unit for the demo app.
2. Determine why the process cannot create its PID file under `/run`.
3. Add the correct systemd runtime directory setting.
4. Confirm the app starts and responds on port 4000.

### Useful Commands

- `systemctl status demo-app.service`
- `systemctl cat demo-app.service`
- `journalctl -u demo-app.service`
- `curl -i http://127.0.0.1:4000/`
