### The Issue

The machine clock was pushed far into the past and the time sync service was disabled. Because of that, TLS certificates were seen as not yet valid, and package updates against the local HTTPS mirror failed.

### Step-by-Step Fix

1. **Check the current clock and service state**:
   ```bash
   timedatectl status
   systemctl status chrony
   ```

2. **Inspect the local mirror certificate**:
   ```bash
   openssl x509 -in /etc/time-lab/certs/server.crt -noout -startdate
   ```
   The certificate start date gives you a trustworthy reference for the expected time window.

3. **Bring the clock back into range**:
   If chrony is disabled, re-enable it and correct the clock:
   ```bash
   sudo systemctl enable --now chrony
   sudo date -u -s "$(openssl x509 -in /etc/time-lab/certs/server.crt -noout -startdate | cut -d= -f2)"
   ```
   If `chronyc makestep` is available and the system already has time sources, that is also acceptable.

4. **Verify package access over HTTPS**:
   ```bash
   sudo apt-get update -o Dir::Etc::sourcelist=/etc/apt/sources.list.d/time-repo.list -o Dir::Etc::sourceparts=-
   ```
   Once the clock is correct, the TLS handshake succeeds and the local apt mirror updates normally.
