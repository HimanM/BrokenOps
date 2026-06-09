#!/bin/bash
set -euo pipefail

sed -i 's/WantedBy=graphical.target/WantedBy=timers.target/' /etc/systemd/system/nightly-backup.timer
systemctl daemon-reload
systemctl enable --now nightly-backup.timer

for _ in {1..10}; do
  if [ -f /var/log/nightly-backup.log ]; then
    break
  fi
  sleep 1
done
