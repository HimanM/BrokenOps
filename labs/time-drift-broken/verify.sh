#!/bin/bash
set -euo pipefail

CERT=/etc/time-lab/certs/server.crt
SOURCE_LIST=/etc/apt/sources.list.d/time-repo.list
LOG=/tmp/time-repo-update.log

if ! systemctl is-active --quiet chrony; then
  echo "FAILURE: chrony is not running."
  exit 1
fi

if [ ! -f "$CERT" ]; then
  echo "FAILURE: The local repository certificate is missing."
  exit 1
fi

START_DATE=$(openssl x509 -in "$CERT" -noout -startdate | cut -d= -f2)
CERT_EPOCH=$(date -u -d "$START_DATE" +%s)
NOW_EPOCH=$(date -u +%s)
DIFF=$((NOW_EPOCH - CERT_EPOCH))
if [ ${DIFF#-} -gt 300 ]; then
  echo "FAILURE: The system clock is still skewed by more than 5 minutes."
  exit 1
fi

if ! apt-get update   -o Dir::Etc::sourcelist="$SOURCE_LIST"   -o Dir::Etc::sourceparts=-   -o APT::Get::List-Cleanup=0 >"$LOG" 2>&1; then
  cat "$LOG"
  echo "FAILURE: apt update against the local HTTPS repository still fails."
  exit 1
fi

echo "SUCCESS: Time sync is restored and the local HTTPS apt repository updates successfully."
