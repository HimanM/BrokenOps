### Scenario
Our main application has stopped being able to connect to the MySQL database after a recent user account audit. The application logs show authentication errors, even though the developers are certain they are using the correct username and password.

### Objective
Diagnose why the `appuser` cannot connect to MySQL using a password and fix the user configuration so that password-based authentication works correctly.

### Useful Commands
- `mysql -u root -e "SELECT user, host, plugin FROM mysql.user;"`
- `mysql -u appuser -p`
- `tail -f /var/log/mysql/error.log`
