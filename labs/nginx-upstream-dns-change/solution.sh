#!/bin/bash
set -euo pipefail

sed -i 's/^10.255.255.1 backend.internal.brokenops$/10.255.255.2 backend.internal.brokenops/' /etc/hosts
systemctl reload nginx
