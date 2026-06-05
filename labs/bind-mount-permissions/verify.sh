#!/bin/bash

rm -f /srv/app-data/result.txt

if ! /usr/local/bin/run-app.sh >/tmp/run-app.log 2>&1; then
  echo "FAILURE: app container still cannot write to the bind mount."
  cat /tmp/run-app.log
  exit 1
fi

if [ ! -f /srv/app-data/result.txt ]; then
  echo "FAILURE: expected /srv/app-data/result.txt to be created."
  exit 1
fi

if ! grep -q "app-write-ok" /srv/app-data/result.txt; then
  echo "FAILURE: output file exists but does not contain expected content."
  exit 1
fi

echo "SUCCESS: container can write to bind-mounted directory."
exit 0
