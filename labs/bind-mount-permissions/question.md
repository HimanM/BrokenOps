### Scenario

A containerized app is configured to write data into `/srv/app-data` through a bind mount, but every run fails with `Permission denied`.

### Objective

Your task is to:
1. Reproduce the failure by running the app launcher script.
2. Fix the permission mismatch between the host mount path and container runtime user.
3. Confirm the app can successfully write to the mounted directory.

### Useful Commands
- `/usr/local/bin/run-app.sh`
- `ls -ld /srv/app-data`
- `docker run --rm --user 1000:1000 -v /srv/app-data:/data busybox:1.36 sh -c 'id && touch /data/test'`
