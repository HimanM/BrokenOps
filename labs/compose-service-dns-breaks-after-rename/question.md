### Scenario
A Compose-based proxy still references an old backend hostname after the service was renamed.

### Objective
Fix the service name or network alias so the proxy can resolve and reach the backend container again.

### Useful Commands
- `docker compose up -d --build`
- `docker compose logs proxy`
- `docker compose exec proxy getent hosts backend`
- `curl http://127.0.0.1:8080/`
