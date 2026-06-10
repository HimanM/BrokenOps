#!/bin/bash

# Enable the rewrite module
a2enmod rewrite

# Restart Apache to apply changes
systemctl restart apache2
