### Scenario
A microservice named `web-app` is running as a Docker container. It is configured to write heartbeat data to a persistent volume mounted at `/data` inside the container, which maps to `/opt/app-data` on the host.

However, the application logs show that it is failing to write to this directory.

### Objective
Diagnose why the container cannot write to the mounted volume and fix the permissions so that the `heartbeat` file can be created.

### Useful Commands
- `docker ps`
- `docker logs web-app`
- `docker inspect web-app`
- `ls -ld /opt/app-data`
- `stat /opt/app-data`
