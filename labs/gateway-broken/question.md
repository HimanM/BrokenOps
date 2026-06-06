### Scenario

A teammate deployed a custom network profile via Netplan under `/etc/netplan/`. Since then, the VM has lost internet connectivity. It can successfully ping the local hypervisor host (`192.168.122.1`) and handle incoming SSH connections, but any connections targeting external networks (like `8.8.8.8`) fail completely.

Locate the broken network configuration and restore standard gateway routing so the VM can reach the internet.

### Objective

Your task is to:
1. Diagnose the network routing table to find the active default gateway.
2. Locate the custom Netplan configuration file under `/etc/netplan/` causing the incorrect routing.
3. Correct or remove the configuration override and restore the default gateway (`192.168.122.1`).
4. Apply network settings using `netplan apply` and confirm external connectivity is working.

### Useful Commands

- `ip route show`
- `netplan apply`
- `ping -c 1 8.8.8.8`
- `ls /etc/netplan/`
