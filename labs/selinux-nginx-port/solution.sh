#!/bin/bash

# 1. Add port 8080 to http_port_t in semanage
semanage port -a -t http_port_t -p tcp 8080

# 2. Restart nginx
systemctl restart nginx
