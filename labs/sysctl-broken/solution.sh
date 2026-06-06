#!/bin/bash
sed -i '/net.ipv4.tcp_tw_recycle/d' /etc/sysctl.d/99-hardening.conf
sed -i 's/net.ipv4.icmp_echo_ignore_all.*/net.ipv4.icmp_echo_ignore_all = 0/' /etc/sysctl.d/99-hardening.conf
sysctl -p /etc/sysctl.d/99-hardening.conf
