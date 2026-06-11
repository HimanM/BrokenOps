### Scenario
The monitoring team has alerted us that the company's main landing page is down, showing a "502 Bad Gateway" error. The Nginx server seems to be running, but it's unable to communicate with the backend application. The issue appeared after a recent upstream change.

### Objective
Diagnose why Nginx cannot reach the backend and restore access to the application.

### Useful Commands
- `curl -I http://localhost`
- `sudo tail -f /var/log/nginx/error.log`
- `ss -tlnp`
- `cat /etc/nginx/sites-available/default`
