### Scenario

Nginx is acting as a reverse proxy for a backend application, but requests to the proxy return an upstream connection failure. The backend itself is still healthy. The issue is that the upstream hostname now resolves to the wrong address.

Fix the hostname mapping and get the reverse proxy working again.

### Objective

1. Inspect the Nginx configuration and identify the upstream hostname.
2. Determine why the upstream name no longer resolves to the backend.
3. Correct the hostname mapping so Nginx can reach the backend again.
4. Confirm the proxy returns the backend response.

### Useful Commands

- `nginx -t`
- `grep api.internal /etc/hosts`
- `systemctl status nginx`
- `curl -i http://127.0.0.1/`
