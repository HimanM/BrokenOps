#!/bin/bash
set -e

systemctl stop systemd-resolved || true
systemctl disable systemd-resolved || true

rm -f /etc/resolv.conf
printf 'nameserver 8.8.8.8\n' > /etc/resolv.conf
