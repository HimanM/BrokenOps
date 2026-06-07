#!/bin/bash

# Disable UseDNS in sshd_config
sed -i 's/UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
# In case it was appended without a previous value
grep -q "^UseDNS no" /etc/ssh/sshd_config || echo "UseDNS no" >> /etc/ssh/sshd_config

# Remove the broken DNS configuration
rm -f /etc/systemd/resolved.conf.d/broken-dns.conf

# Restart services
systemctl restart ssh
systemctl restart systemd-resolved
