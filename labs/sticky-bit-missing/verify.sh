#!/bin/bash

# Ensure the directory exists
if [ ! -d /shared/tmp ]; then
  echo "FAILURE: /shared/tmp directory does not exist."
  exit 1
fi

# Ensure alice's file exists and has correct ownership
if [ ! -f /shared/tmp/alice_secret.txt ]; then
  touch /shared/tmp/alice_secret.txt
  chown alice:alice /shared/tmp/alice_secret.txt
  chmod 0644 /shared/tmp/alice_secret.txt
fi

# Check that the sticky bit is set on /shared/tmp
if [[ ! "$(stat -c "%A" /shared/tmp)" =~ t$ ]]; then
  echo "FAILURE: The sticky bit is not set on /shared/tmp."
  exit 1
fi

# Verify that bob cannot delete alice's file
if su - bob -c "rm -f /shared/tmp/alice_secret.txt" 2>/dev/null; then
  echo "FAILURE: Security check failed. Users can still delete other users' files."
  exit 1
fi

echo "SUCCESS: Sticky bit is set and users cannot delete each other's files!"
exit 0
