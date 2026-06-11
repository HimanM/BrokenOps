### Scenario
The operations team rolled out a new SSL certificate for Nginx, but the web server now refuses to start. The dashboard is down and the on-call engineer needs to identify the certificate mismatch before the site can come back online.

### Objective
Inspect the SSL configuration, identify why Nginx fails during startup, and restore the server so it can bind normally again.

### Useful Commands
- `sudo systemctl status nginx`
- `sudo nginx -t`
- `sudo journalctl -u nginx -n 50`
- `sudo ls -l /etc/nginx/ssl/`
