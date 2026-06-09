#!/bin/bash
set -euo pipefail

python3 - <<'PY'
from pathlib import Path
path = Path('/etc/systemd/system/demo-app.service')
text = path.read_text()
needle = 'Restart=on-failure\n'
insert = 'Restart=on-failure\nRuntimeDirectory=demo-app\nRuntimeDirectoryMode=0755\n'
if 'RuntimeDirectory=demo-app' not in text:
    path.write_text(text.replace(needle, insert, 1))
PY

systemctl daemon-reload
systemctl restart demo-app.service
