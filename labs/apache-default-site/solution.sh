#!/bin/bash

# Disable the default site configuration
a2dissite 000-default.conf

# Reload Apache to apply changes
systemctl reload apache2
