### Scenario
Our organization has just added a new internal subnet, `10.50.0.0/24`, which hosts several key services. Users on this server are reporting that they cannot reach any IP addresses in that range. Networking team has confirmed that traffic to this subnet should be routed through the internal gateway at `192.168.123.1`.

### Objective
Diagnose the reachability issue, add the required static route, and ensure the configuration is persistent so it survives a server reboot.

### Useful Commands
- `ip route show`
- `ping 10.50.0.1`
- `mtr 10.50.0.1`
- `sudo netplan apply`
- `cat /etc/netplan/*.yaml`
