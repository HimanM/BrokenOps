#!/bin/bash

# Ensure systemd service exists
if [ ! -f /etc/systemd/system/web-app.service ]; then
  cat <<'EOF' > /etc/systemd/system/web-app.service
[Unit]
Description=Web Application Container
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=0
Restart=always
ExecStartPre=-/usr/bin/docker stop web-app
ExecStartPre=-/usr/bin/docker rm web-app
ExecStart=/usr/bin/docker run --name web-app --health-cmd "curl -f http://localhost/ || kill 1" --health-interval 5s --health-timeout 2s --health-retries 1 -p 80:80 nginx:alpine
ExecStop=/usr/bin/docker stop web-app

[Install]
WantedBy=multi-user.target
EOF
fi

# Replace curl healthcheck with wget healthcheck and remove the kill command
sed -i 's/--health-cmd "[^"]*"/--health-cmd "wget -qO- http:\/\/localhost\/ || exit 1"/' /etc/systemd/system/web-app.service

# Reload systemd and restart service
systemctl daemon-reload
systemctl restart web-app
