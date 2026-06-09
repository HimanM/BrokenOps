# BrokenOps Lab Format Guide

This guide explains how to create new intentionally broken labs for the BrokenOps platform.

Each lab must be placed in its own folder under the `labs/` directory (e.g., `labs/nginx-broken/`).

## 1. `lab.yaml` (Required)

This is the core definition of your lab. It defines metadata, VM specs, and verification info.

```yaml
id: "nginx-broken"
name: "Nginx Service Down"
category: "linux"
difficulty: "beginner"
description:
  summary: "Nginx is not running after reboot"
vm:
  name: "nginx-lab"
  memory: 1024 # Memory in MB
  cpu: 1
  disk: "10G" # Disk overlay size
cloud_init: "cloud-init.yaml"
verify_script: "verify.sh"
exposed_ports:
  - 80
```

- **`verify_script`**: Name of the verification script inside the lab folder.
- **`exposed_ports`**: (Optional) List of ports that the web UI should provide "Open" buttons for. Adding a port does not make the lab easier by itself; it only tells BrokenOps that users should be able to reach that service through the browser proxy.
- **`port_works_initially`**: (Optional, default `false`) If `true`, the CI test will ensure that the exposed ports successfully return an HTTP 200 response upon initial lab provision. Use this only when the intended broken state is somewhere else and the exposed service is supposed to be healthy from the start.
- When a port is exposed, the service must listen on an interface reachable from outside the VM, not just `127.0.0.1`. The browser proxy connects to the VM over its IP address, so loopback-only listeners will still fail even if `curl http://127.0.0.1:<port>` works inside the guest.
- If you want the port to remain exposed while the lab is still broken, keep `exposed_ports` enabled and make the initial state fail for a different reason, such as a bad upstream address, a missing runtime directory, or an ACL/firewall problem. The goal is for the browser Open Port button to work both before and after the user fixes the lab, without any surprise “works in the guest, fails in the UI” behavior.

## 2. `cloud-init.yaml` (Required)

This file tells the `ubuntu-24.04-base.qcow2` image how to configure itself on first boot. Use this to intentionally break the system.

```yaml
#cloud-config
packages:
  - nginx

runcmd:
  # Intentional break: configure nginx to listen on invalid port to break it
  - sed -i 's/listen 80 default_server;/listen 80808 default_server;/' /etc/nginx/sites-available/default
  - systemctl restart nginx || true
```

## 3. `verify.sh` (Required)

A bash script executed by the backend via SSH to score the user's progress. 
- Print custom output explaining what passed or failed.
- Exit with status `0` if the lab is fully solved (Score 100).
- Exit with status `>0` if the lab is incomplete (Score 0).

```bash
#!/bin/bash
systemctl is-active --quiet nginx
if [ $? -eq 0 ]; then
  echo "SUCCESS: Nginx is running!"
  exit 0
else
  echo "FAILURE: Nginx is not running."
  exit 1
fi
```

## 4. `solution.sh` (Required)

A mandatory bash script that automatically fixes the broken lab.
The CI verification pipeline will execute this script via SSH and then run `verify.sh` to ensure the lab is fully solved. If this script is missing or fails, the CI build will fail.

```bash
#!/bin/bash
# Fix the nginx configuration
sed -i 's/listen 80808 default_server;/listen 80 default_server;/' /etc/nginx/sites-available/default
systemctl restart nginx
```

## 5. `question.md` & `solution.md` (Required)
Markdown files containing the task description and the solution guide. 
- **`question.md`**: Presented immediately to the user.
- **`solution.md`**: Hidden behind a "Reveal Solution" button that only appears after the user attempts Verification.

**Both files MUST follow these strict format templates.**

### `question.md` Template
```markdown
### Scenario
[A brief story or context about the failure]

### Objective
[A bulleted list or paragraph describing what needs to be accomplished]

### Useful Commands
- `command1`
- `command2`
```

### `solution.md` Template
```markdown
### The Issue
[A brief explanation of what was actually broken]

### Step-by-Step Fix
1. **[Action name]**:
   ```bash
   [command]
   ```
2. ...
```
