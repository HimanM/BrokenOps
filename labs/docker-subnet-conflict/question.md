### Scenario
A new containerized application `app_container` has been deployed, but it is failing to communicate with external APIs (specifically failing to ping `8.8.8.8`). The host machine can reach external networks fine, but the container cannot. The team suspects it might be related to the custom Docker network configuration.

### Objective
Diagnose why `app_container` cannot reach external networks like `8.8.8.8` and fix the network configuration so the container regains external connectivity.

### Useful Commands
- `docker ps`
- `docker network ls`
- `docker inspect app_container`
- `docker network inspect broken_net`
- `docker exec app_container ping 8.8.8.8`
