### Scenario
Users are reporting that the `/api/` endpoint of our web application is intermittently failing with `429 Too Many Requests` errors, even when they aren't sending many requests. It seems like the rate limiting configuration is far too strict for normal usage.

### Objective
Adjust the Nginx rate limiting configuration to allow for small bursts of traffic while still protecting the server from abuse. Ensure that a single user can send at least 5 rapid requests without being blocked.

### Useful Commands
- `curl -I http://localhost/api/`
- `tail -f /var/log/nginx/error.log`
- `ls /etc/nginx/conf.d/`
- `nginx -t`
