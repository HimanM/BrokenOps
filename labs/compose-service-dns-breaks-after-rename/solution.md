### The Issue
The proxy container still tries to fetch content from `web`, but the Compose service is now named `backend`.

### Step-by-Step Fix

1. **Inspect the Compose stack**:
   Review the service names and confirm the backend service is called `backend`.

2. **Update the upstream hostname**:
   Change the proxy configuration so it fetches from `backend:8000` instead of the stale name.

3. **Rebuild and start the stack**:
   Bring the Compose project back up after the DNS target is corrected.

4. **Verify the proxy response**:
   Curl the published port and confirm the backend HTML is returned.

5. **Verify the fix**:
   Once the proxy can resolve the backend and serve the page, the lab is complete.
