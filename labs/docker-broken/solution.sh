#!/bin/bash
sed -i '/"bip"/d' /etc/docker/daemon.json
systemctl restart docker
