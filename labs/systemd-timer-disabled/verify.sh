#!/bin/bash
set -euo pipefail

if ! systemctl is-active --quiet cleanup-note.timer; then
  echo "FAILURE: cleanup-note.timer is not active."
  exit 1
fi

if ! systemctl is-enabled --quiet cleanup-note.timer; then
  echo "FAILURE: cleanup-note.timer is not enabled on boot."
  exit 1
fi

if [ ! -f /var/lib/brokenops/cleanup-last-run ]; then
  echo "FAILURE: The scheduled maintenance job has not run yet."
  exit 1
fi

if ! grep -q 'cleanup ran at' /var/lib/brokenops/cleanup.log; then
  echo "FAILURE: The cleanup log does not show a successful timer run."
  exit 1
fi

echo "SUCCESS: The timer is enabled and the maintenance job has run."
