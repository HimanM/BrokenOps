#!/bin/bash

# 1. Check if the file /var/backups/app/latest.tar.gz exists
if [ ! -f /var/backups/app/latest.tar.gz ]; then
  echo "FAILURE: /var/backups/app/latest.tar.gz does not exist."
  exit 1
fi

# 2. Check if the immutable flag is still set on /var/backups/app/latest.tar.gz
if lsattr /var/backups/app/latest.tar.gz | cut -d' ' -f1 | grep -q "i"; then
  echo "FAILURE: The immutable attribute (i) is still set on the destination file."
  exit 1
fi

# 3. Run the backup script and ensure it succeeds
if ! /usr/local/bin/backup.sh; then
  echo "FAILURE: The backup script /usr/local/bin/backup.sh still fails to run."
  exit 1
fi

echo "SUCCESS: The immutable attribute was removed and the backup script runs successfully!"
exit 0
