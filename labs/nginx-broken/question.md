### Scenario

You have just joined a new company as a junior sysadmin. A developer frantically messages you:
> "Hey! The main Nginx web server is completely down on our internal staging box. The service won't start at all after I accidentally rebooted it! I need to test my new frontend right now, can you please fix it?"

### Objective

Investigate why the `nginx` service is failing to start on this machine, fix the root cause, and ensure the service is running. 
Once running, the web server should be accessible via the **"Open Port 80"** button in the top navigation bar. When clicked, it should display the default Nginx welcome page.

### Useful Commands
- `systemctl status nginx`
- `journalctl -xeu nginx.service`
