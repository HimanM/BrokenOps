#!/bin/bash

# We'll fix the rule order by inserting the correct rule at the top or before the drop rule.
# Alternatively, delete the misplaced rules and add them correctly.

# 1. Find the current drop rule index
DROP_INDEX=$(iptables -L INPUT --line-numbers -n | grep "DROP" | grep "dpts:80:100" | awk '{print $1}')

if [ -n "$DROP_INDEX" ]; then
    # Insert the ACCEPT rule at the same position as the DROP rule, pushing the DROP down.
    iptables -I INPUT "$DROP_INDEX" -p tcp --dport 80 -j ACCEPT
    
    # 2. Find and remove the old (now redundant) accept rule at the end
    # We find it by looking for ACCEPT dpt:80 that comes AFTER the DROP rule.
    NEW_DROP_INDEX=$((DROP_INDEX + 1))
    OLD_ACCEPT_INDEX=$(iptables -L INPUT --line-numbers -n | awk -v d=$NEW_DROP_INDEX '$1 > d && $4 == "ACCEPT" && $7 == "dpt:80" {print $1; exit}')
    
    if [ -n "$OLD_ACCEPT_INDEX" ]; then
        iptables -D INPUT "$OLD_ACCEPT_INDEX"
    fi
fi
