#!/bin/bash

PG_HBA=$(find /etc/postgresql -name pg_hba.conf | head -n 1)

# Remove the specific reject lines we added
sed -i '/host appdb appuser 127.0.0.1\/32 reject/d' $PG_HBA
sed -i '/local appdb appuser reject/d' $PG_HBA

systemctl reload postgresql
