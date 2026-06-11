#!/bin/bash
set -euo pipefail
cd /opt/brokenops/docker-multi-stage-copy-path
sed -i 's#COPY --from=builder /out/app.tx /app/app.txt#COPY --from=builder /out/app.txt /app/app.txt#' Dockerfile
