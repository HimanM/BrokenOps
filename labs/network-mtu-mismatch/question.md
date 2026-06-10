### Scenario
Monitoring has identified an unusual network issue on this server: `ping` to external hosts works perfectly, but `curl` or `wget` requests for large files either hang indefinitely or fail with connection timeouts. The network administrator suspects an MTU (Maximum Transmission Unit) mismatch between the server and the local network.

### Objective
Diagnose why large packets are being dropped while small packets pass, identify the misconfigured interface MTU, and restore full network functionality.

### Useful Commands
- `ping -s 1472 -M do google.com` (Test with specific packet size)
- `ip link show eth0`
- `cat /sys/class/net/eth0/mtu`
- `sudo netplan apply`
- `cat /etc/netplan/*.yaml`
