#!/bin/bash
set -euo pipefail

sed -i 's/^192.0.2.10 backend.internal.brokenops$/192.0.2.11 backend.internal.brokenops/' /etc/hosts
systemctl reload nginx
