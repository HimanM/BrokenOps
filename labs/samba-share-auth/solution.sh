#!/bin/bash

# Fix the group name in smb.conf from @engineer to @engineers
sed -i 's/valid users = @engineer/valid users = @engineers/' /etc/samba/smb.conf

# Restart Samba
systemctl restart smbd
