#!/bin/bash

# Check the current default systemd target
DEFAULT_TARGET=$(systemctl get-default)

if [ "$DEFAULT_TARGET" == "multi-user.target" ] || [ "$DEFAULT_TARGET" == "graphical.target" ]; then
    echo "SUCCESS: Default target is $DEFAULT_TARGET"
    exit 0
else
    echo "FAILURE: Default target is still $DEFAULT_TARGET (expected multi-user.target)"
    exit 1
fi
