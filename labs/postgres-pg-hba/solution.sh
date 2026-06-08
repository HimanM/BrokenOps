#!/bin/bash

PG_HBA=$(find /etc/postgresql -name pg_hba.conf | head -n 1)

# Remove the specific reject lines we added
sed -i '/reject/d' $PG_HBA

systemctl reload postgresql
