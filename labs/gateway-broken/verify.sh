#!/bin/bash

# 1. Check the default gateway IP address
gateway=$(ip route show default | awk '{print $3}')
if [ -z "$gateway" ]; then
  echo "FAILURE: No default gateway is currently configured."
  exit 1
fi

if [ "$gateway" = "192.168.122.99" ]; then
  echo "FAILURE: The default gateway is still set to the incorrect IP 192.168.122.99."
  exit 1
fi

# 2. Check if the default gateway is set to the correct host gateway (normally 192.168.122.1)
if [ "$gateway" != "192.168.122.1" ]; then
  echo "FAILURE: The default gateway is set to '$gateway' instead of the correct IP 192.168.122.1."
  exit 1
fi

# 3. Test connectivity to the default gateway
if ! ping -c 1 192.168.122.1 >/dev/null 2>&1; then
  echo "FAILURE: Cannot ping the default gateway 192.168.122.1."
  exit 1
fi


# 5. Ensure that /etc/netplan/99-custom.yaml does not contain the bad gateway
if [ -f /etc/netplan/99-custom.yaml ] && grep -q "192.168.122.99" /etc/netplan/99-custom.yaml; then
  echo "FAILURE: /etc/netplan/99-custom.yaml still contains the invalid gateway."
  exit 1
fi

echo "SUCCESS: Default gateway is corrected and network routing works!"
exit 0
