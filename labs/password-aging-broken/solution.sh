#!/bin/bash

# 1. Remove the account expiration date
chage -E -1 ops-user

# 2. Reset the last password change date to today so the password is no longer expired
chage -d $(date +%F) ops-user
