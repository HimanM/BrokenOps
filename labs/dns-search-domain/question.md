### Scenario
Internal application services use short hostnames to communicate with each other. Recently, developers have reported that they can no longer reach the `api-server` using its short name, although the fully qualified name `api-server.internal.brokenops.io` still works fine. This has broken several automation scripts.

### Objective
Diagnose why short hostname resolution is failing and restore the ability to reach `api-server` by its short name.

### Useful Commands
- `ping api-server`
- `ping api-server.internal.brokenops.io`
- `resolvectl status`
- `cat /etc/resolv.conf`
- `getent hosts api-server`
