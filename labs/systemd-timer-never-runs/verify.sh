#!/bin/bash
set -euo pipefail

if ! systemctl is-enabled --quiet nightly-backup.timer; then
  echo "FAILURE: nightly-backup.timer is not enabled."
  exit 1
fi

if ! systemctl is-active --quiet nightly-backup.timer; then
  echo "FAILURE: nightly-backup.timer is not active."
  exit 1
fi

if [ ! -f /var/log/nightly-backup.log ]; then
  echo "FAILURE: /var/log/nightly-backup.log was not created."
  exit 1
fi

if ! grep -q 'nightly backup completed' /var/log/nightly-backup.log; then
  echo "FAILURE: The backup log does not contain the expected completion message."
  exit 1
fi

echo "SUCCESS: The backup timer is enabled, active, and the backup job ran successfully."
