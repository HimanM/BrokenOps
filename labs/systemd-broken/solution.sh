#!/bin/bash
sed -i 's|ExecStart=/usr/local/bin/demo-service.sh|ExecStart=/usr/local/bin/demo.sh|' /etc/systemd/system/demo.service
systemctl daemon-reload
systemctl reset-failed demo.service
systemctl enable --now demo.service
