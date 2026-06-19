#!/bin/bash
set -euo pipefail

cat > /etc/rsyslog.d/50-forward.conf <<'EOF'
*.* @@127.0.0.1:1514
EOF

systemctl restart rsyslog
