### The Issue
A process named `bad_parent.py` is forking child processes but not calling `wait()` to collect their exit statuses when they terminate. This leaves the children in a "defunct" or "zombie" state (`Z` state in `ps` output). 

You cannot `kill -9` a zombie process directly because it is already dead. To clean up a zombie, you must kill its parent process. When the parent dies, the zombie is "orphaned" and adopted by `init` (PID 1), which automatically calls `wait()` and removes it from the process table.

### Step-by-Step Fix

1. **Verify the problem**:
   Run `ps aux | grep 'Z'` to see the zombie processes.
   ```bash
   ps aux | grep 'Z'
   ```

2. **Identify the parent**:
   Use `ps -ef` or `pstree` to trace the parent of the defunct processes.
   ```bash
   ps -ef | grep defunct
   ```
   Look at the third column (PPID - Parent Process ID) of the defunct processes. Then find the process with that PID:
   ```bash
   ps -p <PPID>
   ```
   You will see it is running `/usr/local/bin/bad_parent.py`.

3. **Kill the parent**:
   Terminate the parent process.
   ```bash
   sudo pkill -f bad_parent.py
   ```
   Or use `kill <PPID>`.

4. **Verify the fix**:
   Run `top` or check `ps` again. The zombies should be gone, as `init` has adopted and reaped them.
   ```bash
   ps aux | grep 'Z'
   ```
