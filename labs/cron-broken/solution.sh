#!/bin/bash
set -euo pipefail

sed -i '1s|^#!.*|#!/bin/bash|' /opt/cleanup.sh
chmod +x /opt/cleanup.sh
systemctl enable --now cron
