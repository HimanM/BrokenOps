### Scenario
The database administrator tried to enable slow query logging to investigate performance issues. After the change was applied, MySQL no longer starts, so the team cannot even inspect the workload. The configuration error has to be corrected before the team can inspect the workload.

### Objective
Find the configuration mistake blocking MySQL startup and restore the service with slow query logging enabled.

### Useful Commands
- `sudo systemctl status mysql`
- `sudo journalctl -u mysql -n 50`
- `cat /etc/mysql/mysql.conf.d/mysqld.cnf`
- `ls -ld /var/log/mysql*`
