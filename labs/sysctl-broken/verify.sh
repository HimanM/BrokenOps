#!/bin/bash

# 1. Check if the configuration file exists
if [ ! -f /etc/sysctl.d/99-hardening.conf ]; then
  echo "FAILURE: /etc/sysctl.d/99-hardening.conf does not exist."
  exit 1
fi

# 2. Check if the obsolete/invalid parameter tcp_tw_recycle is present
if grep -q "tcp_tw_recycle" /etc/sysctl.d/99-hardening.conf; then
  echo "FAILURE: The obsolete parameter net.ipv4.tcp_tw_recycle is still defined in the configuration."
  exit 1
fi

# 3. Check if icmp_echo_ignore_all is set to 0
icmp_val=$(sysctl -n net.ipv4.icmp_echo_ignore_all 2>/dev/null)
if [ "$icmp_val" != "0" ]; then
  echo "FAILURE: net.ipv4.icmp_echo_ignore_all is still set to $icmp_val instead of 0."
  exit 1
fi

# 4. Check if sysctl can load the file without errors
sysctl_err=$(sysctl -p /etc/sysctl.d/99-hardening.conf 2>&1 >/dev/null)
if [ -n "$sysctl_err" ]; then
  echo "FAILURE: Loading sysctl configuration produced errors: $sysctl_err"
  exit 1
fi

# 5. Verify local pings work
if ! ping -c 1 127.0.0.1 >/dev/null 2>&1; then
  echo "FAILURE: Pings to localhost are still failing."
  exit 1
fi

echo "SUCCESS: Sysctl configuration corrected and network stack behaves normally!"
exit 0
