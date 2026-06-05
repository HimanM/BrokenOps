#!/bin/bash

# 1. Check if the swap file exists
if [ ! -f /swapfile ]; then
  echo "FAILURE: The swap file /swapfile does not exist."
  exit 1
fi

# 2. Check if swap is active
if ! swapon --show | grep -q '/swapfile'; then
  echo "FAILURE: Swap file /swapfile is not currently active."
  exit 1
fi

# 3. Check if swap file is in fstab and not commented out
if ! grep -v '^#' /etc/fstab | grep -q '/swapfile'; then
  echo "FAILURE: Swap file /swapfile is not configured in /etc/fstab or is commented out."
  exit 1
fi

# 4. Check if the fstab configuration is valid by running swapon -a
sudo swapon -a
if [ $? -ne 0 ]; then
  echo "FAILURE: The fstab entry for the swap file is invalid."
  exit 1
fi

echo "SUCCESS: Swap file is active and persistently configured in /etc/fstab!"
exit 0
