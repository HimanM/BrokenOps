### Scenario

A backend hostname moved to a new IP address after provisioning, but Nginx kept forwarding traffic to the old address it resolved earlier. The backend is healthy, yet the reverse proxy now returns errors until it is refreshed.

### Objective

1. Inspect the Nginx reverse proxy and backend hostname setup.
2. Determine why Nginx is still talking to the old upstream address.
3. Refresh the proxy so it resolves the backend's current address.
4. Confirm the proxy returns the backend response again.

### Useful Commands

- `systemctl status nginx`
- `systemctl cat nginx`
- `getent hosts backend.internal.brokenops`
- `curl -i http://localhost/`
