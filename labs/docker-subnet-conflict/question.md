### Scenario
A new containerized application `app_container` has been deployed, but it is failing to communicate with the host network and external APIs. The team suspects it might be related to the custom Docker network configuration conflicting with the host's primary network.

### Objective
Diagnose why `app_container` cannot reach the host's IP address and fix the network configuration so the container regains external connectivity.

### Useful Commands
- `ip a` (to find the host IP)
- `docker network ls`
- `docker inspect app_container`
- `docker network inspect broken_net`
- `docker exec app_container ping <HOST_IP>`
