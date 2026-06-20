### Scenario

A maintenance script stopped refreshing packages after the machine's clock drifted far into the past. HTTPS requests now fail with certificate time errors, and the local package mirror no longer updates cleanly.

Restore the system clock and time synchronization so TLS checks and package operations work again.

### Objective

1. Inspect the system clock and time synchronization status.
2. Find why the machine time is skewed far into the past.
3. Restore proper time sync and confirm TLS and apt operations work again.

### Useful Commands

- `timedatectl status`
- `systemctl status chrony`
- `openssl x509 -in /etc/time-lab/certs/server.crt -noout -startdate`
- `apt-get update -o Dir::Etc::sourcelist=/etc/apt/sources.list.d/time-repo.list -o Dir::Etc::sourceparts=-`
