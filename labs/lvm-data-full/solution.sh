#!/bin/bash

# 1. Extend the logical volume using 100% of the free space in the volume group
lvextend -l +100%FREE /dev/vg_data/lv_data

# 2. Resize the ext4 filesystem online
resize2fs /dev/vg_data/lv_data
