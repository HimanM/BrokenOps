### Scenario
The development team reports that they cannot pull any Docker images on this new server. While they can access the internet using `curl` (which they have already configured with a proxy), Docker commands simply hang or time out.

### Objective
Configure the Docker daemon to correctly use the corporate proxy so that it can pull images from external registries.

### Useful Commands
- `docker pull alpine`
- `systemctl status docker`
- `journalctl -u docker -n 50`
- `ls /etc/systemd/system/docker.service.d/`
