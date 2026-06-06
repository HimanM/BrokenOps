#!/bin/bash
visudo -c -f /etc/sudoers.d/ops || true
sed -i 's/ops ALL=(ALL:ALL)/ops ALL=(ALL:ALL) NOPASSWD:ALL/' /etc/sudoers.d/ops
