### Scenario

You are troubleshooting a host behind a corporate proxy. General internet access works from the host, but `docker pull` keeps timing out.

### Objective

Your task is to:
1. Identify why Docker pulls fail while the host still has internet access.
2. Configure Docker daemon proxy settings using a **systemd drop-in**.
3. Restart Docker and verify that pulling an image succeeds.

### Useful Commands
- `systemctl show docker --property=Environment`
- `systemctl cat docker`
- `docker pull hello-world`
