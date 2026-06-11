### Scenario
The server was rebooted for maintenance, but instead of coming up normally it drops into rescue or maintenance mode. The hosted applications never start, and the team needs the machine back in its standard boot target. The fix needs to happen before users notice the outage. The team wants a clean return to normal boot behavior, not a temporary workaround.

### Objective
Diagnose why the host is booting into rescue mode and restore the default multi-user target.

### Useful Commands
- `systemctl get-default`
- `systemctl set-default`
- `systemctl list-units --type target`
