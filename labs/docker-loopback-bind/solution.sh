#!/bin/bash
set -euo pipefail
cd /opt/brokenops/docker-loopback-bind
sed -i "s/127.0.0.1/0.0.0.0/" server.py
