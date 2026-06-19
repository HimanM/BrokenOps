#!/bin/bash
set -euo pipefail

LOG_FILE=/var/log/collector.log
TEST_TAG=brokenops-rsyslog
TEST_MESSAGE="rsyslog forwarding test $(date -Is)"

if ! systemctl is-active --quiet rsyslog; then
  echo "FAILURE: rsyslog is not running."
  exit 1
fi

if ! rsyslogd -N1 >/tmp/rsyslog-syntax.log 2>&1; then
  cat /tmp/rsyslog-syntax.log
  echo "FAILURE: rsyslog configuration still has syntax errors."
  exit 1
fi

logger -t "$TEST_TAG" "$TEST_MESSAGE"
sleep 2

if [ ! -f "$LOG_FILE" ]; then
  echo "FAILURE: The collector log was not created."
  exit 1
fi

if ! grep -q "$TEST_TAG" "$LOG_FILE" || ! grep -q "$TEST_MESSAGE" "$LOG_FILE"; then
  echo "FAILURE: The forwarded log message never reached the collector."
  exit 1
fi

echo "SUCCESS: rsyslog forwards messages to the remote collector successfully."
