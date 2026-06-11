### The Issue
The Dockerfile passes `--bind` to an app that expects `--host`. That mismatch makes the container exit before it can finish startup.

### Step-by-Step Fix

1. **Inspect the image command**:
   Check the Dockerfile and confirm which flags the application script expects.

2. **Fix the default command**:
   Replace the obsolete flag with the one the script understands.

3. **Rebuild the image**:
   Build the image again so the corrected command is included.

4. **Run the container**:
   Confirm the container prints `ready on 0.0.0.0:8080` and exits successfully.

5. **Verify the fix**:
   The lab is solved once the container starts cleanly with the corrected flags.
