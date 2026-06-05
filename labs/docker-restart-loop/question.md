### Scenario

A web application container `web-app` has been deployed on this server. It is configured to run automatically via a systemd service. However, monitoring reports that the service is highly unstable and is constantly restarting in a loop, preventing users from accessing it reliably.

Investigate the container configuration, diagnose the root cause of the restart loop, and fix the configuration so the container remains running and healthy.

### Objective

1. Identify the container `web-app` and confirm it is repeatedly restarting.
2. Investigate the container logs and inspect the healthcheck definition to find out why it fails.
3. Edit the systemd service `/etc/systemd/system/web-app.service` to fix the healthcheck command.
4. Reload the systemd daemon, restart the service, and verify the container is healthy and stable.

### Useful Commands

- `docker ps -a`
- `docker logs web-app`
- `docker inspect web-app`
- `sudo systemctl status web-app`
- `sudo systemctl daemon-reload`
