### Scenario
A web developer has deployed a simple custom application on this Apache server. They created a new virtual host configuration and enabled it using `a2ensite`. However, when they test the site locally, they are still seeing the default Apache "It works!" page instead of the "Custom App" content.

### Objective
Diagnose why Apache is still serving the default site and fix the configuration so that the custom application is served on port 80.

### Useful Commands
- `curl http://localhost`
- `apache2ctl -S`
- `ls /etc/apache2/sites-enabled/`
- `sudo a2dissite [site]`
- `sudo systemctl reload apache2`
