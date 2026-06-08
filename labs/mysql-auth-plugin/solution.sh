#!/bin/bash

# Change the authentication plugin for 'appuser' to 'mysql_native_password' (compatible with most clients)
mysql -e "ALTER USER 'appuser'@'localhost' IDENTIFIED WITH 'mysql_native_password' BY 'apppassword';"
mysql -e "FLUSH PRIVILEGES;"
