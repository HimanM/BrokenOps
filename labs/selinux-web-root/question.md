### Scenario
A web application has been deployed to the directory `/var/www/html/` on the server. Although the index file `/var/www/html/index.html` exists and is readable by Nginx, visitors receive a `403 Forbidden` error when trying to access the website.

The server has SELinux configured in enforcing mode. You must investigate the file's security settings, find the source of the denial, and restore the correct security context on the web root files so that the website can be served.

### Objective
Restore access to the website:
1. Diagnose why Nginx cannot access `/var/www/html/index.html`.
2. Find the SELinux file context on the web root and locate the AVC denial in the audit logs.
3. Correct the SELinux security context on `/var/www/html/index.html` (recursively for `/var/www/html/` if needed) to the standard web content context.
4. Verify that Nginx successfully returns the page with HTTP 200.

### Useful Commands
- `ls -Z`
- `sestatus`
- `restorecon`
- `chcon`
- `tail -n 100 /var/log/audit/audit.log`
