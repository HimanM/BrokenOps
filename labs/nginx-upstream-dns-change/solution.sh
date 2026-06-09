#!/bin/bash
set -euo pipefail

sed -i 's/^127.0.0.2 backend.internal.brokenops$/127.0.0.3 backend.internal.brokenops/' /etc/hosts
systemctl reload nginx
