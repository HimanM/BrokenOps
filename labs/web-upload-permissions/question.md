### Scenario
A web portal has been set up to allow internal users to upload system logs for analysis. While the portal homepage loads perfectly fine, trying to upload any file results in a generic failure message. 

The developer has verified that the PHP script is receiving the files, but for some reason, they are not being saved in the `/var/www/html/uploads/` directory.

### Objective
Diagnose and repair the file upload issue so that users can successfully upload files, and simulating an upload using `curl` to `http://localhost/index.php` returns `UPLOAD_SUCCESS`.

### Useful Commands
- `curl -I http://localhost/`
- `tail -n 50 /var/log/nginx/error.log`
- `tail -n 50 /var/log/php8.3-fpm.log`
- `ls -ld /var/www/html/uploads`
- `namei -l /var/www/html/uploads`
