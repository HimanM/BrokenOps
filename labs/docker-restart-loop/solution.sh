#!/bin/bash
sed -i 's/|| kill 1/|| exit 1/' /etc/systemd/system/web-app.service
systemctl daemon-reload
systemctl restart web-app
