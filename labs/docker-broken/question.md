### Scenario
The development team standardized Docker settings across their hosts, but the daemon will not start after a configuration change. Container workloads are offline until the daemon configuration is corrected. Container workloads are offline until the daemon configuration is corrected, so this host needs a quick but careful recovery.

### Objective
Diagnose the Docker daemon failure, fix the configuration problem, and bring the service back online.

### Useful Commands
- `sudo systemctl status docker`
- `sudo journalctl -u docker -n 50`
- `sudo dockerd --validate`
- `cat /etc/docker/daemon.json`
