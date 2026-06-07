#!/bin/bash

# Update the exports file to allow the local subnet (or all hosts for simplicity)
sed -i 's|192.0.2.0/24|*|g' /etc/exports

# Reload the exports
exportfs -ra

# Ensure NFS service is happy
systemctl restart nfs-kernel-server
