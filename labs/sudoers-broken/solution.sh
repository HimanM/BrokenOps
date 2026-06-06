#!/bin/bash
# Fix the syntax error in /etc/sudoers.d/ops
echo "ops ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/ops
chmod 0440 /etc/sudoers.d/ops
