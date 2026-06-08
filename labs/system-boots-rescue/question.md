### Scenario
The server was recently rebooted for maintenance, but now it fails to start normal services. Every time it boots, it seems to land in a restricted maintenance or rescue mode. The team is unable to reach the hosted applications.

### Objective
Diagnose why the system is booting into rescue mode and restore it to its normal operational state (multi-user mode).

### Useful Commands
- `systemctl get-default`
- `systemctl set-default`
- `systemctl list-units --type target`
