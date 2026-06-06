#!/bin/bash

# 1. Correct group ownership of the directory and all existing files recursively to devs
chgrp -R devs /var/shared/project

# 2. Add the setgid bit to the shared directory
chmod g+s /var/shared/project

# 3. Ensure read and write permissions for the group on files and directories recursively
chmod -R g+rw /var/shared/project

# 4. Ensure directories inside are executable (traversable) for group members
find /var/shared/project -type d -exec chmod g+x {} +
