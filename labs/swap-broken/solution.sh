#!/bin/bash
set -euo pipefail

grep -qxF '/swapfile none swap sw 0 0' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
swapon /swapfile
