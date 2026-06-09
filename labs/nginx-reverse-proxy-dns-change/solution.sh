#!/bin/bash
set -euo pipefail

sed -i 's/10.255.255.1 api.internal/127.0.0.1 api.internal/' /etc/hosts
systemctl restart nginx
