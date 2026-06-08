#!/bin/bash

# Find and kill the bad_parent.py process
pkill -f bad_parent.py || true

# Wait for zombies to be reaped (up to 10 seconds)
for i in {1..10}; do
    ZOMBIE_COUNT=$(ps -axo stat | grep -c "^Z")
    if [ "$ZOMBIE_COUNT" -eq 0 ]; then
        break
    fi
    sleep 1
done
