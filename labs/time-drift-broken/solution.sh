#!/bin/bash
set -euo pipefail

systemctl enable --now chrony >/dev/null 2>&1 || true
cert_date=$(openssl x509 -in /etc/time-lab/certs/server.crt -noout -startdate | cut -d= -f2)
date -u -s "$cert_date" >/dev/null
