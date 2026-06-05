#!/bin/bash

# Remove any carriage returns from the service file first
sed -i 's/\r//g' /etc/systemd/system/demo.service

# Edit the ExecStart line in demo.service to point to /usr/local/bin/demo.sh
sed -i 's|ExecStart=/usr/local/bin/demo-service.sh|ExecStart=/usr/local/bin/demo.sh|' /etc/systemd/system/demo.service

# Reload daemon and restart service
systemctl daemon-reload
systemctl enable demo
systemctl restart demo
