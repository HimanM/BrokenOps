### Scenario

A shared directory `/shared/tmp` was set up for users on the server to exchange temporary files. However, users have reported that their files are being deleted by other users on the system. You need to secure the directory so that users can write to it, but cannot delete or rename files owned by others.

### Objective

Your task is to:
1. Inspect the permissions of the `/shared/tmp` directory.
2. Configure permissions so that all users can create files, but only a file's owner (or root) can delete or rename it.
3. Verify the restriction is active.

### Useful Commands

- `ls -ld /shared/tmp`
- `stat /shared/tmp`
- `chmod`
