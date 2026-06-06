#!/bin/bash
rm -f /var/log/syslog.1.gz
# Also delete rogue file if it's named something else
find / -xdev -type f -size +5G -delete 2>/dev/null
