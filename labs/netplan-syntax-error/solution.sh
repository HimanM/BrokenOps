#!/bin/bash
rm -f /etc/netplan/99-broken.yaml
netplan apply
