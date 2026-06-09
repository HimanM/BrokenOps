#!/bin/bash
set -euo pipefail

if ! dpkg -s labtool >/dev/null 2>&1; then
  echo "FAILURE: labtool is not installed."
  exit 1
fi

if ! command -v labtool >/dev/null 2>&1; then
  echo "FAILURE: labtool is not on PATH."
  exit 1
fi

if ! labtool --version | grep -q 'labtool 1.0'; then
  echo "FAILURE: labtool does not report the expected version."
  exit 1
fi

if ! curl -fsS https://localhost:8443/labtool_1.0_all.deb -o /tmp/labtool.deb; then
  echo "FAILURE: HTTPS download of the package still fails."
  exit 1
fi

echo "SUCCESS: HTTPS downloads work and the bootstrap package is installed."
