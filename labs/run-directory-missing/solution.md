### The Issue

The service writes a PID file into `/run/demo-app`, but the unit file never asks systemd to create that runtime directory. As a result, the app fails before it can bind to its port. The app was also bound only to `127.0.0.1`, which meant the lab's browser proxy could not reach it even after the service came up. Reloading the unit alone is not enough; systemd needs the runtime directory directive in place first, and the app must listen on the VM-reachable interface.

### Step-by-Step Fix

1. **Tell systemd to create the runtime directory**:
   ```bash
   python3 - <<'PY'
   from pathlib import Path
   path = Path('/etc/systemd/system/demo-app.service')
   text = path.read_text()
   needle = 'Restart=on-failure\n'
   insert = 'Restart=on-failure\nRuntimeDirectory=demo-app\nRuntimeDirectoryMode=0755\n'
   if 'RuntimeDirectory=demo-app' not in text:
       path.write_text(text.replace(needle, insert, 1))
   PY
   ```
2. **Allow the app to listen on the VM interface**:
   ```bash
   python3 - <<'PY'
   from pathlib import Path
   path = Path('/usr/local/bin/demo-app.sh')
   text = path.read_text()
   if '--bind 0.0.0.0' not in text:
       path.write_text(text.replace('--bind 127.0.0.1', '--bind 0.0.0.0', 1))
   PY
   ```
3. **Reload systemd and restart the service**:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl restart demo-app.service
   ```
4. **Verify the app is running locally and through the lab proxy**:
   ```bash
   curl -fsS http://127.0.0.1:4000/
   ```
