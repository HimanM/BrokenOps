### The Issue
PostgreSQL uses a file named `pg_hba.conf` (Host-Based Authentication) to control client authentication. This file contains a set of rules that are evaluated from top to bottom. The first rule that matches the connection type, database, user, and IP address is applied. In this scenario, restrictive `reject` rules were placed at the top of the file, explicitly denying `appuser` access to `appdb`.

### Step-by-Step Fix

1. **Verify the error**:
   Attempt to connect as the application user.
   ```bash
   psql -h 127.0.0.1 -U appuser -d appdb
   # Password is apppassword
   ```
   You will see an error clearly stating that `pg_hba.conf` rejected the connection.

2. **Locate the configuration file**:
   Find where `pg_hba.conf` is stored on your system.
   ```bash
   find /etc/postgresql -name pg_hba.conf
   ```

3. **Inspect and edit the file**:
   Open the file with a text editor (you'll need `sudo`).
   ```bash
   sudo vi /etc/postgresql/16/main/pg_hba.conf # Path may vary based on PG version
   ```
   At the very top of the file, you will find lines like:
   ```text
   local appdb appuser reject
   host appdb appuser 127.0.0.1/32 reject
   ```

4. **Remove or change the rules**:
   Delete those `reject` lines. The default rules further down the file (e.g., `host all all 127.0.0.1/32 scram-sha-256` or `md5`) will then allow the connection since the user has a valid password.

5. **Reload PostgreSQL**:
   Changes to `pg_hba.conf` do not require a full restart, only a reload.
   ```bash
   sudo systemctl reload postgresql
   ```

6. **Verify the fix**:
   Attempt the connection again.
   ```bash
   psql -h 127.0.0.1 -U appuser -d appdb
   ```
   It should now prompt for the password and connect successfully.
