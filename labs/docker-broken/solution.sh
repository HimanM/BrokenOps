#!/bin/bash
sed -i 's/"log-level": "warn"/"log-level": "warn",/' /etc/docker/daemon.json
systemctl restart docker
