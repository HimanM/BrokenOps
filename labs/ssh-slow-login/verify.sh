#!/bin/bash

# Check if UseDNS is explicitly disabled
if grep -qi "^UseDNS no" /etc/ssh/sshd_config; then
    echo "SUCCESS: UseDNS is disabled. SSH logins should be fast now."
    exit 0
fi

# Or check if the broken DNS config was removed
if [ ! -f /etc/systemd/resolved.conf.d/broken-dns.conf ]; then
    echo "SUCCESS: Broken DNS configuration was removed."
    exit 0
fi

echo "FAILURE: UseDNS is still enabled and broken DNS config exists."
exit 1
