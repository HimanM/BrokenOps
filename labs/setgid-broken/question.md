### Scenario
The engineering team set up a shared directory at `/var/shared/project` to collaborate on project files. Both developers `alice` and `bob` are members of the `devs` group, which owns the directory. 

However, they are having trouble collaborating. Whenever `alice` creates a new file, it belongs to her personal primary group `alice`. When `bob` attempts to edit or write to those files, he gets a "Permission denied" error because they don't inherit the `devs` group ownership. The team needs you to configure this directory so that collaboration is seamless.

### Objective
Configure the `/var/shared/project` directory so that:
1. The directory and all existing files inside it belong to the `devs` group.
2. All future files and directories created inside `/var/shared/project` automatically inherit the group ownership of `devs` (regardless of who creates them).
3. Members of the `devs` group have read/write access to these files.

### Useful Commands
- `chgrp`
- `chmod`
- `stat`
- `ls`
