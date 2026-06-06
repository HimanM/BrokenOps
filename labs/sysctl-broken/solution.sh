#!/bin/bash
# Remove net.ipv4.tcp_tw_recycle line from the custom configuration file
sed -i '/tcp_tw_recycle/d' /etc/sysctl.d/99-hardening.conf

# Set net.ipv4.icmp_echo_ignore_all to 0
sed -i 's/net.ipv4.icmp_echo_ignore_all = 1/net.ipv4.icmp_echo_ignore_all = 0/g' /etc/sysctl.d/99-hardening.conf

# Apply the configurations
sysctl --system
