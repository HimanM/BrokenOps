#!/bin/bash
ip route del default via 192.168.122.99 || true
ip route add default via 192.168.122.1
sed -i 's/192.168.122.99/192.168.122.1/' /etc/netplan/99-custom.yaml || true
netplan apply
