#!/bin/bash
chattr -i /var/backups/app/latest.tar.gz || true
/usr/local/bin/backup.sh
