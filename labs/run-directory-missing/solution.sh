#!/bin/bash
set -euo pipefail

sed -i '/^Restart=on-failure$/a RuntimeDirectory=demo-app
RuntimeDirectoryMode=0755' /etc/systemd/system/demo-app.service
systemctl daemon-reload
systemctl restart demo-app.service
