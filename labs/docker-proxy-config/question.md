### Scenario
The developers can reach the internet from the shell, but Docker itself cannot pull images because it is not using the corporate proxy configuration. Image pulls stall until the daemon is pointed at the correct proxy. The daemon's own service settings need to be corrected so image pulls can work again.

### Objective
Configure the Docker daemon to use the required proxy settings so it can pull images from external registries again.

### Useful Commands
- `docker pull alpine`
- `sudo systemctl status docker`
- `sudo journalctl -u docker -n 50`
- `ls /etc/systemd/system/docker.service.d/`
