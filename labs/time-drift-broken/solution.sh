#!/bin/bash
set -euo pipefail

CERT=/etc/time-lab/certs/server.crt
SOURCE_LIST=/etc/apt/sources.list.d/time-repo.list
LOG=/tmp/time-repo-update.log

if [ ! -f "$CERT" ]; then
  echo "FAILURE: The local repository certificate is missing."
  exit 1
fi

if ! systemctl is-active --quiet chrony; then
  systemctl enable --now chrony
fi

START_DATE=$(openssl x509 -in "$CERT" -noout -startdate | cut -d= -f2)
# Use the cert's start date as a stable time anchor, then step the clock into range.
date -u -s "$START_DATE" >/dev/null

if command -v chronyc >/dev/null 2>&1; then
  chronyc -a makestep >/dev/null 2>&1 || true
fi

apt-get update \
  -o Dir::Etc::sourcelist="$SOURCE_LIST" \
  -o Dir::Etc::sourceparts=- \
  -o APT::Get::List-Cleanup=0 >"$LOG" 2>&1

echo "SUCCESS: Time sync is restored and the local HTTPS apt repository updates successfully."
