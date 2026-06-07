### Scenario
The application team is reporting that their service is failing to connect to the database. They keep seeing the error: `FATAL: sorry, too many clients already`. Interestingly, the database administrator is still able to log in using the `postgres` superuser account.

### Objective
Identify the cause of the connection exhaustion for normal users, terminate the rogue connections, and ensure the `appuser` can connect again.

### Useful Commands
- `ps aux | grep python`
- `sudo -u postgres psql -c "SELECT pid, usename, state, query FROM pg_stat_activity;"`
- `sudo -u postgres psql -c "SELECT pg_terminate_backend(pid) FROM ..."`
- `sudo -u postgres psql -c "SHOW max_connections;"`
- `psql -h localhost -U appuser -d postgres`
