#!/bin/bash
chmod +x /usr/local/bin/demo.sh
sed -i 's|ExecStart=.*|ExecStart=/usr/local/bin/demo.sh|' /etc/systemd/system/demo.service
systemctl daemon-reload
systemctl enable --now demo.service
