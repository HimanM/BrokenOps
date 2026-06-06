#!/bin/bash

# Restore default SELinux context recursively for /var/www/html
restorecon -R /var/www/html
