### Scenario
The host is reachable, but Docker commands hang because the daemon was left in a broken state after a previous maintenance change. The team cannot deploy containers until the service is healthy again. The fix needs to restore the daemon without disturbing the rest of the machine. The on-call engineer needs to bring it back without a full rebuild.

### Objective
Determine why the Docker daemon will not start and restore normal container management on the host.

### Useful Commands
- `sudo systemctl status docker`
- `sudo journalctl -u docker`
- `docker ps`
