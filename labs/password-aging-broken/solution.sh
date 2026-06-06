#!/bin/bash
chage -I -1 -m 0 -M 99999 -E -1 ops-user
# Force password reset so it's not expired immediately
passwd -d ops-user
