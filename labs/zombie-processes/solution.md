### The Issue
A parent process is spawning child processes and never reaping them after they exit. That leaves the children in a zombie state, which is a symptom of the real bug: the parent is not calling `wait()` or an equivalent cleanup path.

### Step-by-Step Fix

1. **Confirm that the problem is really zombies**:
   Look for processes in the `Z` state and identify the parent process behind them.
   ```bash
   ps aux | grep ' Z '
   ps -ef | grep defunct
   ```

2. **Trace the parent-child relationship**:
   Use the PPID to find the parent that is failing to reap its children.
   ```bash
   ps -p <PPID> -o pid,ppid,cmd
   ```

3. **Stop the broken parent process**:
   You cannot kill a zombie directly, so the practical recovery is to stop the parent that created it. Once the parent dies, `init` adopts the orphaned children and reaps them.
   - Optional helper: `sudo pkill -f bad_parent.py`

4. **Verify the zombies disappear**:
   Run the process listing again and confirm the `Z` entries are gone.
   ```bash
   ps aux | grep ' Z '
   ```

5. **Understand the code fix**:
   If this were an application change, the real code fix would be to call `wait()`/`waitpid()` for each child so the parent reaps exits instead of leaking zombies.
