#!/bin/bash
set -euo pipefail

sed -i 's/^10.10.10.10 backend.internal.brokenops$/10.10.10.11 backend.internal.brokenops/' /etc/hosts
systemctl reload nginx
