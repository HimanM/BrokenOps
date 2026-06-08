#!/bin/bash

# Check if bad_parent.py is still running
if pgrep -f bad_parent.py > /dev/null; then
    echo "FAILURE: The bad_parent process is still running."
    exit 1
fi

# Check if there are any defunct processes belonging to the bad_parent.py script
# Defunct processes often show up with the parent's command name in <defunct> brackets
ZOMBIE_PIDS=$(ps -axo pid,stat,comm | grep " Z" | grep "bad_parent.py" | awk '{print $1}')
if [ -n "$ZOMBIE_PIDS" ]; then
    echo "FAILURE: Zombie processes from bad_parent.py still detected: $ZOMBIE_PIDS"
    exit 1
fi

echo "SUCCESS: Bad parent killed and its zombies reaped."
exit 0
