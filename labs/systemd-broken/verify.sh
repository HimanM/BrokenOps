#!/bin/bash

# 1. Check if the script exists and is executable
if [ ! -x /usr/local/bin/demo.sh ]; then
  echo "FAILURE: The script /usr/local/bin/demo.sh does not exist or is not executable."
  exit 1
fi

# 2. Check if the service file exists
if [ ! -f /etc/systemd/system/demo.service ]; then
  echo "FAILURE: The systemd service file /etc/systemd/system/demo.service does not exist."
  exit 1
fi

# 3. Check if the service file was corrected
if ! grep -q 'ExecStart=/usr/local/bin/demo.sh' /etc/systemd/system/demo.service; then
  echo "FAILURE: The ExecStart path in /etc/systemd/system/demo.service is still invalid or incorrect."
  exit 1
fi

# 4. Check if systemd daemon was reloaded and the service is active
systemctl is-active --quiet demo
if [ $? -ne 0 ]; then
  echo "FAILURE: The demo service is not currently active."
  exit 1
fi

# 5. Check if the service is enabled on boot
systemctl is-enabled --quiet demo >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "FAILURE: The demo service is not enabled to start on boot."
  exit 1
fi

echo "SUCCESS: The systemd service is active, enabled on boot, and has the correct executable path!"
exit 0
