#!/bin/bash

# Correct the syntax error in the custom logrotate configuration
sed -i 's/missing_ok/missingok/g' /etc/logrotate.d/noisy-app

# Force run logrotate to rotate the logs and confirm it works
logrotate -f /etc/logrotate.d/noisy-app
