#!/bin/bash
set -euo pipefail

update-ca-certificates
systemctl restart lab-bootstrap.service
