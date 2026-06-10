### Scenario
This server was recently migrated to a new virtual environment. While the primary network interface is working fine, the secondary interface, which is supposed to be used for internal database traffic, is not coming up. The previous admin left a Netplan configuration that they claimed should work.

### Objective
Diagnose why the secondary network interface is down, identify any naming mismatches in the configuration, and restore connectivity on the correct interface with the assigned IP `10.10.10.10`.

### Useful Commands
- `ip addr`
- `ip link show`
- `cat /etc/netplan/60-internal-nic.yaml`
- `sudo netplan apply`
