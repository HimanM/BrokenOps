#!/bin/bash
echo '8080' >> /etc/selinux/allowed_ports.txt
systemctl restart nginx
