#!/bin/bash

# 1. Check if vg_data/lv_data exists
if ! lvs vg_data/lv_data >/dev/null 2>&1; then
  echo "FAILURE: Logical volume vg_data/lv_data does not exist."
  exit 1
fi

# 2. Check if /data is mounted
if ! mountpoint -q /data; then
  echo "FAILURE: /data is not mounted."
  exit 1
fi

# 3. Check the total capacity of /data (should be at least 1.2GB)
capacity_kb=$(df -k /data | awk 'NR==2 {print $2}')
if [ -z "$capacity_kb" ] || [ "$capacity_kb" -lt 1200000 ]; then
  echo "FAILURE: The capacity of /data is only $((capacity_kb / 1024))MB. It should be extended to at least 1.2GB."
  exit 1
fi

# 4. Check the free space of /data (should be at least 500MB free)
free_kb=$(df -k /data | awk 'NR==2 {print $4}')
if [ -z "$free_kb" ] || [ "$free_kb" -lt 500000 ]; then
  echo "FAILURE: The free space of /data is only $((free_kb / 1024))MB. Free up or extend the filesystem to have at least 500MB free."
  exit 1
fi

echo "SUCCESS: The logical volume and filesystem have been extended successfully!"
exit 0
