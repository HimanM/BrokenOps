### Scenario
A newly deployed web server has been configured to host a PHP application. While testing, the operations team noticed that static pages load perfectly fine, but attempting to access any PHP page (such as `index.php`) returns a `502 Bad Gateway` error. 

The developer insists that the PHP-FPM process is running and the application code is correct. You need to investigate the communication channel between Nginx and PHP-FPM and fix the connection issue.

### Objective
Fix the configuration so that Nginx can successfully process and serve PHP pages, and accessing `http://localhost/index.php` returns `HTTP 200` with the content `PHP is working!`.

### Useful Commands
- `systemctl status nginx`
- `systemctl status php8.3-fpm`
- `curl -I http://localhost/index.php`
- `ss -xl`
- `ls -la /run/php/`
