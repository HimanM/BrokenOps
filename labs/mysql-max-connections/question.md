### Scenario
The application team reports that their service is frequently crashing with "Too many connections" errors from the MySQL database during peak traffic. The server itself is not under high CPU or memory load, suggesting it's an artificial limit.

### Objective
Diagnose the connection limit issue, terminate any rogue connections, and configure MySQL to handle a higher number of concurrent connections safely.

### Useful Commands
- `mysql -u root -e "SHOW VARIABLES LIKE 'max_connections';"`
- `mysql -u root -e "SHOW PROCESSLIST;"`
- `ps aux | grep python`
- `cat /etc/mysql/mysql.conf.d/*.cnf`
