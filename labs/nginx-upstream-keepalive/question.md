### Scenario
The company's API is occasionally returning "502 Bad Gateway" errors, especially during periods of moderate activity. After checking the Nginx error logs, you see messages like `upstream prematurely closed connection while reading response header from upstream`.

It appears that Nginx is configured to use keepalive connections to the backend, but it's not correctly managing them, leading it to try and use connections that the backend has already closed.

### Objective
Diagnose why the upstream keepalive is failing and fix the Nginx configuration to correctly support persistent connections to the backend nodes.

### Useful Commands
- `curl -I http://localhost`
- `sudo tail -f /var/log/nginx/error.log`
- `cat /etc/nginx/sites-available/default`
- `nginx -t`
- `sudo systemctl restart nginx`
