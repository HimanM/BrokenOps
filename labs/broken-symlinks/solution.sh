#!/bin/bash

# Fix the soft link
rm -f /opt/app/config/current_config
ln -s /opt/app/new_location/app_config /opt/app/config/current_config

# Fix the hard link (by replacing the bad file with a hard link to the correct one)
rm -f /opt/app/data/current_db
ln /opt/app/new_location/app_db /opt/app/data/current_db
