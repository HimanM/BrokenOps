### Scenario
A new frontend application has been deployed at `https://app.brokenops.io`. While the site loads, it is unable to fetch any data from the API hosted on this server. Browser developer tools show errors like: `Access to fetch at 'http://[IP]/api/data.json' from origin 'https://app.brokenops.io' has been blocked by CORS policy`.

### Objective
Configure Nginx to correctly handle Cross-Origin Resource Sharing (CORS) so that the frontend application can successfully communicate with the API. You must handle both preflight (OPTIONS) and actual (GET/POST) requests.

### Useful Commands
- `curl -X OPTIONS -H "Origin: https://app.brokenops.io" -I http://localhost/api/data.json`
- `curl -H "Origin: https://app.brokenops.io" -I http://localhost/api/data.json`
- `sudo tail -f /var/log/nginx/error.log`
- `sudo nano /etc/nginx/sites-available/default`
- `sudo systemctl restart nginx`
