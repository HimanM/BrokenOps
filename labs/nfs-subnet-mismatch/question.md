### Scenario
The engineering team is trying to mount a shared data directory from this server using NFS. However, every attempt to mount the share results in an "Access denied" error. The directory permissions on the server appear to be open (`777`), but the share remains unreachable.

### Objective
Diagnose why the NFS share is denying access and fix the configuration so that clients (including the server itself) can mount it.

### Useful Commands
- `showmount -e localhost`
- `exportfs -v`
- `cat /etc/exports`
- `mount -t nfs [IP]:/srv/nfs/shared /mnt`
