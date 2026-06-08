#!/bin/bash

# Check the active systemd target
ACTIVE_TARGET=$(systemctl list-units --type=target --state=active | grep -E "multi-user.target|graphical.target")

# Also check the default target
DEFAULT_TARGET=$(systemctl get-default)

if [ -n "$ACTIVE_TARGET" ] && [[ "$DEFAULT_TARGET" == *"multi-user.target"* || "$DEFAULT_TARGET" == *"graphical.target"* ]]; then
    echo "SUCCESS: Active target is multi-user/graphical and default is $DEFAULT_TARGET"
    exit 0
else
    echo "FAILURE: System is not fully running multi-user target (Default: $DEFAULT_TARGET)"
    exit 1
fi
