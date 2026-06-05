#!/bin/bash

# 1. Check if the script exists
if [ ! -f /opt/cleanup.sh ]; then
  echo "FAILURE: The cleanup script /opt/cleanup.sh does not exist."
  exit 1
fi

# 2. Check if the script is executable
if [ ! -x /opt/cleanup.sh ]; then
  echo "FAILURE: The cleanup script /opt/cleanup.sh is not executable."
  exit 1
fi

# 3. Check if the shebang is valid
SHEBANG=$(head -n 1 /opt/cleanup.sh)
if [[ ! "$SHEBANG" =~ ^#!\s*/bin/(bash|sh)\s*$ ]] && [[ ! "$SHEBANG" =~ ^#!\s*/usr/bin/env\s+(bash|sh)\s*$ ]]; then
  echo "FAILURE: The shebang '$SHEBANG' in /opt/cleanup.sh is invalid."
  exit 1
fi

# 4. Check if the cron job is scheduled
if [ ! -f /etc/cron.d/cleanup ]; then
  echo "FAILURE: The cron configuration /etc/cron.d/cleanup does not exist."
  exit 1
fi

if ! grep -q 'opt/cleanup.sh' /etc/cron.d/cleanup; then
  echo "FAILURE: The cleanup script is not scheduled in /etc/cron.d/cleanup."
  exit 1
fi

# 5. Check if direct execution works
/opt/cleanup.sh
if [ $? -ne 0 ]; then
  echo "FAILURE: Running /opt/cleanup.sh directly failed."
  exit 1
fi

# 6. Check if cron daemon is active
systemctl is-active --quiet cron
if [ $? -ne 0 ]; then
  echo "FAILURE: The cron service is not running."
  exit 1
fi

echo "SUCCESS: Cron job is configured, executable, has a valid shebang, and cron service is active!"
exit 0
