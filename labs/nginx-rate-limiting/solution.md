### The Issue
Nginx rate limiting was set far too aggressively: the base rate was only `1r/m`, and the configuration did not leave any burst room for normal browser retries or quick back-to-back API calls. That makes the endpoint feel broken even though the server is up.

### Step-by-Step Fix

1. **Confirm the symptom**:
   Send one or two requests to the API and note the `429 Too Many Requests` response.
   ```bash
   curl -I http://localhost/api/
   ```

2. **Inspect the rate-limit configuration**:
   Check the shared zone and the site configuration that applies the rule.
   ```bash
   ls /etc/nginx/conf.d/
   cat /etc/nginx/conf.d/rate_limit.conf
   cat /etc/nginx/sites-available/default
   ```

3. **Adjust the rule to allow brief bursts**:
   Increase the base rate and add a `burst` value in the `limit_req` directive so normal user behavior does not get blocked immediately.

4. **Reload Nginx and test again**:
   Validate the config, reload the service, then repeat the request from step 1.
   ```bash
   sudo nginx -t
   sudo systemctl restart nginx
   ```

5. **Verify the fix**:
   After the reload, the endpoint should answer normally instead of rate-limiting ordinary traffic.
