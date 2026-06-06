#!/bin/bash
UUID=$(blkid -s UUID -o value /opt/data.img)
sed -i "s|invalid_ext4|ext4|" /etc/fstab
# Ensure UUID is correct if it was mangled
sed -i "s|^UUID=.* /mnt/data |UUID=$UUID /mnt/data |" /etc/fstab
mount -a
