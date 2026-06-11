### Scenario
A developer has deployed a PHP application on this Apache server. The application relies on "clean URLs" (e.g., visiting `/dashboard` instead of `/index.php?page=dashboard`). While the main page and static files work correctly, any attempt to visit a custom route results in a standard Apache 404 Not Found error.

The developer has already provided an `.htaccess` file in the application directory which should handle this routing.

### Objective
Diagnose why the clean URLs are not working and fix the Apache configuration to support the application's routing requirements.

### Useful Commands
- `curl -I http://localhost/test-route`
- `apache2ctl -M`
- `sudo a2enmod [module]`
- `cat /etc/apache2/sites-available/app.conf`
- `sudo systemctl restart apache2`
