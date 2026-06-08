### Scenario
The development team has deployed a new application that needs to connect to the local PostgreSQL database (`appdb`) using the `appuser` account. However, every time the application tries to connect, it receives a "FATAL: pg_hba.conf rejects connection" error. 

### Objective
Diagnose the connection rejection issue, locate the PostgreSQL configuration file responsible, and modify it so that `appuser` can successfully connect to `appdb` from `localhost` (127.0.0.1) using password authentication.

### Useful Commands
- `psql -h 127.0.0.1 -U appuser -d appdb`
- `find /etc/postgresql -name pg_hba.conf`
- `cat /var/log/postgresql/postgresql-*-main.log`
- `sudo systemctl reload postgresql`
