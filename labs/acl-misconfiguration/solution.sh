#!/bin/bash
setfacl -b /var/log/webapp
chown root:webapp /var/log/webapp
chmod 775 /var/log/webapp
