#!/bin/bash
sed -i 's/ops ALL=(ALL:ALL) NOPASSWD: ALL_BROKEN_SYNTAX/ops ALL=(ALL:ALL) NOPASSWD:ALL/' /etc/sudoers.d/ops
