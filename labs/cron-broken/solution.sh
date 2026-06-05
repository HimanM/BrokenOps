#!/bin/bash

# Ensure file exists
if [ ! -f /opt/cleanup.sh ]; then
  mkdir -p /opt
  echo -e '#!/bin/bash\necho "Cleanup run at $(date)" >> /var/log/cleanup.log' > /opt/cleanup.sh
fi

# Fix the shebang
sed -i 's|^#!/bin/sh_invalid|#!/bin/bash|' /opt/cleanup.sh

# Make the script executable
chmod +x /opt/cleanup.sh

# Ensure cron is running and schedule is correct
if [ ! -f /etc/cron.d/cleanup ]; then
  echo "* * * * * root /opt/cleanup.sh" > /etc/cron.d/cleanup
  chmod 644 /etc/cron.d/cleanup
fi

systemctl restart cron || systemctl start cron
