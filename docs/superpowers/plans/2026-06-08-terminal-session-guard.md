# Terminal Session Guard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prevent destructive session-ending commands from terminating BrokenOps labs by intercepting them in the backend terminal bridge, without changing any lab folder contents.

**Architecture:** Add a small backend helper that generates a restricted interactive bash rcfile. The websocket SSH terminal will create a per-session rcfile on the VM, start bash with that rcfile, and clean it up when the session ends. Normal lab commands still pass through; only shutdown/reboot-style commands are blocked.

**Tech Stack:** Python, FastAPI, asyncssh, pytest

---

### Task 1: Add restricted shell helper

**Files:**
- Create: `backend/shell_sandbox.py`
- Test: `tests/test_shell_sandbox.py`

- [ ] **Step 1: Write the failing test**

```python
from backend.shell_sandbox import build_restricted_shell_command, build_restricted_shell_rcfile


def test_restricted_shell_rcfile_blocks_power_commands():
    rcfile = build_restricted_shell_rcfile()

    assert "brokenops_blocked_command()" in rcfile
    assert "shutdown()" in rcfile
    assert "reboot()" in rcfile
    assert "poweroff()" in rcfile
    assert "halt()" in rcfile
    assert "init()" in rcfile
    assert "telinit()" in rcfile
    assert "systemctl()" in rcfile
    assert 'command not found' in rcfile


def test_restricted_shell_command_uses_temp_rcfile():
    command = build_restricted_shell_command("/tmp/brokenops-shell.rc")

    assert command == "bash --noprofile --rcfile /tmp/brokenops-shell.rc -i"
```

- [ ] **Step 2: Run test to verify it fails**

Run: `python -m pytest tests/test_shell_sandbox.py -q`
Expected: FAIL because the helper module does not exist yet.

- [ ] **Step 3: Write minimal implementation**

```python
from __future__ import annotations

import textwrap


def build_restricted_shell_rcfile() -> str:
    return textwrap.dedent(
        """
        brokenops_blocked_command() {
            printf 'bash: %s: command not found\\n' "$1"
            return 127
        }

        shutdown() { brokenops_blocked_command shutdown; }
        reboot() { brokenops_blocked_command reboot; }
        poweroff() { brokenops_blocked_command poweroff; }
        halt() { brokenops_blocked_command halt; }

        sudo() {
            case "$1" in
                reboot|poweroff|halt|shutdown)
                    brokenops_blocked_command "$1"
                    ;;
                systemctl)
                    case "$2" in
                        reboot|poweroff|halt)
                            brokenops_blocked_command systemctl
                            ;;
                        *)
                            command sudo "$@"
                            ;;
                    esac
                    ;;
                *)
                    command sudo "$@"
                    ;;
            esac
        }

        init() {
            case "$1" in
                0|6)
                    brokenops_blocked_command init
                    ;;
                *)
                    command init "$@"
                    ;;
            esac
        }

        telinit() {
            case "$1" in
                0|6)
                    brokenops_blocked_command telinit
                    ;;
                *)
                    command telinit "$@"
                    ;;
            esac
        }

        systemctl() {
            case "$1" in
                reboot|poweroff|halt)
                    brokenops_blocked_command systemctl
                    ;;
                *)
                    command systemctl "$@"
                    ;;
            esac
        }
        """
    ).strip() + "\n"


def build_restricted_shell_command(rcfile_path: str) -> str:
    return f"bash --noprofile --rcfile {rcfile_path} -i"
```

- [ ] **Step 4: Run test to verify it passes**

Run: `python -m pytest tests/test_shell_sandbox.py -q`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add backend/shell_sandbox.py tests/test_shell_sandbox.py
git commit -m "feat: add restricted lab shell helper"
```

### Task 2: Wire the websocket terminal to use the restricted shell

**Files:**
- Modify: `backend/main.py`

- [ ] **Step 1: Add the terminal helper import and per-session rcfile setup**

```python
import shlex
import uuid

try:
    from backend.shell_sandbox import build_restricted_shell_command, build_restricted_shell_rcfile
except ImportError:
    from shell_sandbox import build_restricted_shell_command, build_restricted_shell_rcfile
```

- [ ] **Step 2: Create the rcfile on the VM before opening the shell**

```python
restricted_rcfile_path = f"/tmp/brokenops-shell-{uuid.uuid4().hex}.rc"
restricted_rcfile = build_restricted_shell_rcfile()
rcfile_command = (
    f"cat > {shlex.quote(restricted_rcfile_path)} <<'BROKENOPS_RC'\n"
    f"{restricted_rcfile}"
    "BROKENOPS_RC\n"
    f"chmod 600 {shlex.quote(restricted_rcfile_path)}"
)
await conn.run(rcfile_command, check=True)
```

- [ ] **Step 3: Start bash with the restricted rcfile and clean it up afterward**

```python
shell_command = build_restricted_shell_command(restricted_rcfile_path)
async with conn.create_process(shell_command, term_type='xterm') as process:
    ...
finally:
    try:
        await conn.run(f"rm -f {shlex.quote(restricted_rcfile_path)}", check=False)
    except Exception:
        pass
```

- [ ] **Step 4: Run backend smoke verification**

Run: `python -m pytest tests/test_shell_sandbox.py -q`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add backend/main.py
git commit -m "feat: restrict destructive terminal commands"
```
