#!/bin/bash

# 1. Check if /mnt/data is currently mounted
if ! mountpoint -q /mnt/data; then
  echo "FAILURE: /mnt/data is not mounted."
  exit 1
fi

# 2. Check if the verification file exists and contains the correct string
if [ ! -f /mnt/data/active.txt ] || [ "$(cat /mnt/data/active.txt)" != "Volume mounted successfully!" ]; then
  echo "FAILURE: The verification file at /mnt/data/active.txt is missing or incorrect."
  exit 1
fi

# 3. Get the real UUID of /opt/data.img
real_uuid=$(blkid -s UUID -o value /opt/data.img)
if [ -z "$real_uuid" ]; then
  echo "FAILURE: Could not retrieve the UUID of /opt/data.img."
  exit 1
fi

# 4. Verify that /etc/fstab contains the correct UUID
if ! grep -q "$real_uuid" /etc/fstab; then
  echo "FAILURE: /etc/fstab does not contain the correct UUID ($real_uuid) for /mnt/data."
  exit 1
fi

echo "SUCCESS: Volume is mounted successfully with the correct UUID in /etc/fstab!"
exit 0
