### Scenario
Internal services rely on short hostnames, but a recent hosts-file edit broke lookups for `api-server`. The fully qualified hostname still works, which makes the issue look like a DNS problem at first glance. The on-call engineer needs to spot that this is a hosts-file issue, not a DNS outage.

### Objective
Restore short-name resolution for `api-server` by correcting the `/etc/hosts` entry.

### Useful Commands
- `getent hosts api-server`
- `getent hosts api-server.internal.brokenops.io`
- `cat /etc/hosts`
