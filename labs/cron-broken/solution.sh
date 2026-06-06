#!/bin/bash
sed -i 's|#!/bin/sh_invalid|#!/bin/sh|' /opt/cleanup.sh
chmod +x /opt/cleanup.sh
echo "* * * * * root /opt/cleanup.sh" > /etc/cron.d/cleanup
chmod 644 /etc/cron.d/cleanup
systemctl restart cron
