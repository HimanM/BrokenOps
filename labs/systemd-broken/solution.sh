#!/bin/bash

# Remove any carriage returns from the service file first
sed -i 's/\r//g' /etc/systemd/system/demo.service

# Edit the ExecStart line in demo.service to point to /usr/local/bin/demo.sh
sed -i 's|ExecStart=/usr/local/bin/demo-service.sh|ExecStart=/usr/local/bin/demo.sh|' /etc/systemd/system/demo.service

# Reload daemon, reset failed state, and restart service
systemctl daemon-reload
systemctl reset-failed demo
systemctl enable demo

if ! systemctl restart demo; then
  echo "=== DEBUG: systemctl status demo ==="
  systemctl status demo --no-pager
  echo "=== DEBUG: journalctl -u demo ==="
  journalctl -u demo -n 50 --no-pager
  exit 1
fi
