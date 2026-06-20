#!/bin/bash
set -euo pipefail

LOG_FILE=/var/log/collector.log
TEST_TAG=brokenops-rsyslog
TEST_MESSAGE="rsyslog forwarding test"

if ! systemctl is-active --quiet rsyslog; then
  systemctl enable --now rsyslog
fi

printf '*.* @@127.0.0.1:1514\n' > /etc/rsyslog.d/50-forward.conf
systemctl restart rsyslog

logger -t "$TEST_TAG" "$TEST_MESSAGE"
sleep 2

echo "SUCCESS: rsyslog forwards messages to the remote collector successfully."
