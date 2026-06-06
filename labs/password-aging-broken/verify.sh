#!/bin/bash

# 1. Check if the user ops-user exists
if ! id ops-user >/dev/null 2>&1; then
  echo "FAILURE: The user ops-user does not exist."
  exit 1
fi

# Get the shadow entry for ops-user
shadow_entry=$(getent shadow ops-user)
if [ -z "$shadow_entry" ]; then
  echo "FAILURE: Could not retrieve shadow entry for ops-user."
  exit 1
fi

# Extract relevant fields (1-indexed, separated by colon)
# field 3: last password change date
# field 8: account expiration date
last_passwd_change=$(echo "$shadow_entry" | cut -d: -f3)
account_expire=$(echo "$shadow_entry" | cut -d: -f8)

# Current days since epoch
current_days=$(( $(date +%s) / 86400 ))

# 2. Check if the account has expired or is set to expire in the past
if [ -n "$account_expire" ]; then
  if [ "$account_expire" -le "$current_days" ]; then
    echo "FAILURE: The account ops-user is expired (expiration field: $account_expire, current: $current_days)."
    exit 1
  fi
fi

# 3. Check if the password is set to be changed immediately (expired)
if [ "$last_passwd_change" = "0" ]; then
  echo "FAILURE: The password for ops-user is still expired and requires change on next login."
  exit 1
fi

echo "SUCCESS: The ops-user account and password aging policies have been successfully corrected!"
exit 0
