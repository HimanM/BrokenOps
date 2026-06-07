#!/bin/bash

# Check if UseDNS is explicitly disabled
if grep -qi "^UseDNS no" /etc/ssh/sshd_config; then
    echo "SUCCESS: UseDNS is disabled. SSH logins should be fast now."
    exit 0
fi

# Check the active resolver state using resolvectl
# If the broken DNS server (192.0.2.1) is still listed in the active config, it's not fixed
if resolvectl status | grep -q "192.0.2.1"; then
    echo "FAILURE: The unreachable DNS server (192.0.2.1) is still active in the resolver."
    exit 1
fi

# Also ensure the broken config file is gone to prevent it returning after next restart
if [ -f /etc/systemd/resolved.conf.d/broken-dns.conf ]; then
    echo "FAILURE: The broken DNS configuration file still exists."
    exit 1
fi

echo "SUCCESS: Broken DNS configuration is removed and no longer active."
exit 0
