#!/bin/bash
mkdir -p /var/shared/project
chown root:devs /var/shared/project
chmod g+s /var/shared/project
find /var/shared/project -type f -exec chown root:devs {} \;
