#!/bin/bash
# Get the real UUID of the disk image
real_uuid=$(blkid -s UUID -o value /opt/data.img)

# Replace the incorrect UUID in /etc/fstab with the correct one
sed -i "s/12345678-abcd-ef01-2345-6789abcdef01/$real_uuid/g" /etc/fstab

# Mount the filesystem
mount -a
