#!/bin/bash

# Check if logrotate configuration exists
if [ ! -f /etc/logrotate.d/noisy-app ]; then
  echo "FAILURE: Logrotate configuration file /etc/logrotate.d/noisy-app does not exist."
  exit 1
fi

# Run dry run and check for errors
DEBUG_OUTPUT=$(logrotate -d /etc/logrotate.d/noisy-app 2>&1)
if echo "$DEBUG_OUTPUT" | grep -qi "error:"; then
  echo "FAILURE: Logrotate configuration contains syntax errors."
  echo "$DEBUG_OUTPUT" | grep -i "error:"
  exit 1
fi

# Force run logrotate to check if rotation succeeds
logrotate -f /etc/logrotate.d/noisy-app > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "FAILURE: Logrotate command execution failed."
  exit 1
fi

# Check if rotated log file exists
if [ -f /var/log/noisy-app.log.1 ] || [ -f /var/log/noisy-app.log.1.gz ] || [ -f /var/log/noisy-app.log.1.tmp ]; then
  echo "SUCCESS: Log file successfully rotated."
  exit 0
else
  echo "FAILURE: Rotated log file was not created. Configuration or directory issue."
  exit 1
fi
