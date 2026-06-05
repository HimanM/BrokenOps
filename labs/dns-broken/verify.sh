#!/bin/bash

if grep -Eq '^\s*nameserver\s+127\.0\.0\.99(\s|$)' /etc/resolv.conf; then
  echo "FAILURE: /etc/resolv.conf is still using the broken nameserver 127.0.0.99."
  exit 1
fi

if ! getent hosts google.com > /dev/null 2>&1; then
  echo "FAILURE: DNS resolution still fails for google.com."
  exit 1
fi

echo "SUCCESS: DNS resolution is working again."
exit 0
