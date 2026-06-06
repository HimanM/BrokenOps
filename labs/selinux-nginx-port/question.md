### Scenario
A web developer recently changed the Nginx server configuration on the server to listen on port `8080` instead of the default port `80`.

After making the change and trying to restart the service, Nginx fails to start due to permission errors. The security policy on the server is currently configured in enforcing mode. You must investigate the audit logs, identify what is blocking the service, and resolve it so Nginx can start and serve requests on the custom port.

### Objective
Configure the system so that Nginx can listen and serve traffic on port `8080`:
1. Diagnose why Nginx fails to start (inspect the logs and security status).
2. Allow Nginx to bind to the custom port `8080` without disabling security policies.
3. Restart Nginx and confirm it returns HTTP 200 on port 8080.

### Useful Commands
- `systemctl status nginx`
- `sestatus`
- `semanage`
- `curl`
