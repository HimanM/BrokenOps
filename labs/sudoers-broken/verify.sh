#!/bin/bash

# 1. Check for syntax errors in sudoers configuration
if ! visudo -c >/dev/null 2>&1; then
  echo "FAILURE: Sudoers configuration has syntax errors."
  exit 1
fi

# 2. Verify that /etc/sudoers.d/ops exists and is configured correctly
if [ ! -f /etc/sudoers.d/ops ]; then
  echo "FAILURE: Drop-in file /etc/sudoers.d/ops is missing."
  exit 1
fi

# 3. Check if the file still contains the broken pattern
if grep -q "ALL_BROKEN_SYNTAX" /etc/sudoers.d/ops; then
  echo "FAILURE: The syntax error in /etc/sudoers.d/ops has not been corrected."
  exit 1
fi

# 4. Verify that the ops user has passwordless sudo privilege
if ! sudo -l -U ops | grep -q "NOPASSWD"; then
  echo "FAILURE: The ops user does not have passwordless sudo privileges configured."
  exit 1
fi

# 5. Run a command as the ops user with sudo to verify it works
if ! su - ops -c "sudo -n true" >/dev/null 2>&1; then
  echo "FAILURE: The ops user cannot execute sudo commands successfully."
  exit 1
fi

echo "SUCCESS: Sudoers configuration fixed and ops user has active sudo privileges!"
exit 0
