### The Issue
The app binds to `127.0.0.1` inside the container, so Docker's port publishing cannot reach it.

### Step-by-Step Fix

1. **Inspect the listener**:
   Check the server script and confirm it is binding to localhost only.

2. **Change the bind address**:
   Update the server to listen on `0.0.0.0` so Docker can forward traffic to it.

3. **Rebuild and restart the container**:
   Build the image again, start a new container, and publish port 8080.

4. **Test the published port**:
   Curl `http://127.0.0.1:8080/` from the VM and confirm the response comes back.

5. **Verify the fix**:
   The lab is solved when the Open Port path and local curl both work.
