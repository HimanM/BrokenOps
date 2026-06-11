### Scenario
Our web server is running and the Nginx service is confirmed to be listening on port 80. However, internal users and external monitoring tools report that the website is unreachable. A junior admin recently updated the firewall rules to block a ranges of unneeded ports, and it's possible something was misconfigured.

### Objective
Diagnose why the web traffic is being blocked despite an "allow" rule existing, and fix the firewall configuration to restore access while keeping the other security policies intact.

### Useful Commands
- `sudo iptables -L -n --line-numbers`
- `curl -I http://localhost` (Test locally)
- `sudo iptables -I INPUT [number] ...` (Insert a rule)
- `sudo iptables -D INPUT [number]` (Delete a rule)
- `sudo systemctl status nginx`
