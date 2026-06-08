#!/bin/bash

# Check if bad_parent.py is still running
if pgrep -f bad_parent.py > /dev/null; then
    echo "FAILURE: The bad_parent process is still running."
    exit 1
fi

# Check if there are any zombie processes left from bad_parent
# Z state indicates zombie. We can just check overall zombies if we assume a clean system, 
# or specifically check if any processes exist with 'Z' state.
ZOMBIE_COUNT=$(ps -axo stat | grep -c "^Z")
if [ "$ZOMBIE_COUNT" -gt 0 ]; then
    echo "FAILURE: There are still $ZOMBIE_COUNT zombie processes on the system."
    exit 1
fi

echo "SUCCESS: Bad parent killed and zombies reaped."
exit 0
