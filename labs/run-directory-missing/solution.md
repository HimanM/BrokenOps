### The Issue

The service writes a PID file into `/run/demo-app`, but the unit file never asks systemd to create that runtime directory. As a result, the app fails before it can bind to its port. Reloading the unit alone is not enough; systemd needs the runtime directory directive in place first.

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
2. **Reload systemd and restart the service**:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl restart demo-app.service
   ```
3. **Verify the app is running**:
   ```bash
   curl -fsS http://127.0.0.1:4000/
   ```
