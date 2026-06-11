#!/bin/bash

# 1. Check that opsuser is in the sudo group
if ! groups opsuser | grep -qw "sudo"; then
    echo "FAILURE: opsuser is not in the sudo group."
    exit 1
fi

# 2. Check that the dangerous NOPASSWD find rule has been removed
if grep -q "opsuser ALL=(root) NOPASSWD: /usr/bin/find" /etc/sudoers; then
    echo "FAILURE: The dangerous sudo rule for find is still present."
    exit 1
fi

# 3. Check that sudoers syntax is valid
if ! visudo -c > /dev/null 2>&1; then
    echo "FAILURE: /etc/sudoers has syntax errors."
    exit 1
fi

echo "SUCCESS: Root access has been restored. opsuser can now use sudo."
exit 0