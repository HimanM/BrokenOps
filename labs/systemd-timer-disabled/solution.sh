#!/bin/bash
set -euo pipefail

systemctl daemon-reload
systemctl enable --now cleanup-note.timer
