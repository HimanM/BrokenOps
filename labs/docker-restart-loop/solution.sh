#!/bin/bash
sed -i 's/curl -f http:\/\/localhost\/ || kill 1/wget -qO- http:\/\/localhost\/ || exit 1/' /etc/systemd/system/web-app.service
systemctl daemon-reload
systemctl restart web-app
