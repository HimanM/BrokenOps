### The Issue
The MySQL `max_connections` parameter was set to an artificially low value (10). Combined with a simulated workload that opens multiple persistent connections, all available slots were exhausted, preventing new legitimate connections from the application.

### Step-by-Step Fix

1. **Verify the error**:
   Try connecting to the database.
   ```bash
   mysql -u appuser -p'apppassword'
   ```
   You should see `ERROR 1040 (HY000): Too many connections`.

2. **Diagnose as root**:
   The root user has a reserved connection slot (if `max_connections` is reached + 1). Connect as root.
   ```bash
   sudo mysql -u root
   ```

3. **Check the connection limit**:
   ```sql
   SHOW VARIABLES LIKE 'max_connections';
   ```
   You will see it is set to `10`.

4. **Identify the load**:
   ```sql
   SHOW PROCESSLIST;
   ```
   You will see multiple sleepy connections. You can identify the script holding them open by checking the process list:
   ```bash
   ps aux | grep exhaust
   ```

5. **Kill the simulated load**:
   ```bash
   sudo pkill -f exhaust_mysql.py
   ```

6. **Increase the limit**:
   You can change it dynamically without restart:
   ```sql
   SET GLOBAL max_connections = 200;
   ```
   To make it persistent, edit the configuration file (usually in `/etc/mysql/mysql.conf.d/`):
   ```bash
   sudo sed -i 's/max_connections = 10/max_connections = 200/' /etc/mysql/mysql.conf.d/zz-broken.cnf
   sudo systemctl restart mysql
   ```

7. **Verify**:
   The application user should now be able to connect freely.
   ```bash
   mysql -u appuser -p'apppassword' -e "SELECT 1;"
   ```
