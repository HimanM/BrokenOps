#!/bin/bash
# Remove the immutable flag from the target file
chattr -i /var/backups/app/latest.tar.gz

# Execute the backup script to ensure it is fully resolved
/usr/local/bin/backup.sh
