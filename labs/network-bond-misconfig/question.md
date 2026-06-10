### Scenario
The infrastructure team is setting up a high-bandwidth server and requires an adaptive load-balancing bond (`balance-alb`) across two network interfaces. However, the current configuration is only using one interface at a time (active-backup), and it seems to be flapping under load.

### Objective
Diagnose the current bonding configuration, identify why it's not using adaptive load balancing, and fix the Netplan configuration to meet the requirement.

### Useful Commands
- `cat /proc/net/bonding/bond0`
- `ip link show`
- `sudo netplan apply`
- `cat /etc/netplan/60-bond.yaml`
