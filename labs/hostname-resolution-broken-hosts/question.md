### Scenario
Internal services use short hostnames to communicate. Recently, lookups for `api-server` stopped working, even though the fully qualified hostname still resolves.

### Objective
Restore short-name resolution for `api-server` by fixing `/etc/hosts`.

### Useful Commands
- `getent hosts api-server`
- `getent hosts api-server.internal.brokenops.io`
- `cat /etc/hosts`
