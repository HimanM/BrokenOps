### Scenario
A junior administrator added a second network interface profile to the server, but the new Netplan YAML does not parse. Every attempt to apply networking changes now fails, leaving the host in a half-configured state. The host needs to be cleaned up before the next maintenance window.

### Objective
Find the syntax problem in the Netplan configuration and restore the ability to apply network settings cleanly.

### Useful Commands
- `sudo netplan apply`
- `sudo netplan generate`
- `ls /etc/netplan/`
- `sudo cat /etc/netplan/*.yaml`
