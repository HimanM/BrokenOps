### The Issue
YAML syntax error in `/etc/netplan/99-broken.yaml`.
### Step-by-Step Fix
1. Run `sudo netplan apply` to see the error.
2. Remove or fix the broken file in `/etc/netplan/`.
3. Run `sudo netplan apply` again.
