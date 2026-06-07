### The Issue
Mismatched SSL cert and key.
### Step-by-Step Fix
1. Run `nginx -t`.
2. Compare moduli with `openssl`.
3. Restore the correct key and restart Nginx.
