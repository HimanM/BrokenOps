### Scenario

Nginx was reconfigured to use port **8080** on a host where SELinux is expected to remain enforcing.  
The service appears configured, but the app is unreachable.

### Objective

Find and fix the SELinux policy issue preventing HTTP service on the custom port while keeping SELinux enforcing.

When solved:
- Nginx should run on **port 8080**
- SELinux should allow HTTP traffic on 8080 (`http_port_t` mapping)
- The **"Open Port 8080"** button should load the Nginx default page

### Useful Commands
- `systemctl status nginx`
- `journalctl -xeu nginx.service`
- `ausearch -m avc -ts recent`
- `semanage port -l | grep http_port_t`
