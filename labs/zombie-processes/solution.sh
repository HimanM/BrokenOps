#!/bin/bash

# Find and kill the bad_parent.py process
pkill -f bad_parent.py || true

# Wait a moment for init to reap the orphaned zombies
sleep 2
