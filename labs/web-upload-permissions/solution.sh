#!/bin/bash

# Fix the ownership of the uploads directory to the web server user (www-data)
chown -R www-data:www-data /var/www/html/uploads

# Ensure it has correct write permissions
chmod 755 /var/www/html/uploads
