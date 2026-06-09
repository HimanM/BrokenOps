#!/bin/bash
set -euo pipefail
if grep -qE '^10\.0\.0\.50[[:space:]].*api-server[[:space:]].*api-server\.internal\.brokenops\.io' /etc/hosts; then
  exit 0
fi

if grep -qE '^10\.0\.0\.50[[:space:]].*api-server\.internal\.brokenops\.io' /etc/hosts; then
  sed -i 's/^10\.0\.0\.50[[:space:]].*api-server\.internal\.brokenops\.io$/10.0.0.50 api-server api-server.internal.brokenops.io/' /etc/hosts
else
  echo '10.0.0.50 api-server api-server.internal.brokenops.io' >> /etc/hosts
fi

getent hosts api-server >/dev/null
