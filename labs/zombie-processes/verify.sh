#!/bin/bash

# Check if bad_parent.py is still running
if pgrep -f bad_parent.py > /dev/null; then
    echo "FAILURE: The bad_parent process is still running."
    exit 1
fi

# Check if there are any defunct processes belonging to the now-killed bad_parent
# Since the parent is dead, they should have been reaped by init.
# If we still see zombies that were children of bad_parent (tracked by name or association), it's a failure.
# More simply: check for ANY zombie. If some exist, verify they aren't from our lab.
ZOMBIE_PIDS=$(ps -axo pid,stat,comm | grep " Z" | awk '{print $1}')
if [ -n "$ZOMBIE_PIDS" ]; then
    # If zombies exist, check if they are related to our script (though after parent dies, they should be gone)
    echo "FAILURE: Zombie processes still detected: $ZOMBIE_PIDS"
    exit 1
fi

echo "SUCCESS: Bad parent killed and zombies reaped."
exit 0
