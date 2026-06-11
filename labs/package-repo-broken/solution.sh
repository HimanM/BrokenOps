#!/bin/bash

# Remove the broken repository file
rm -f /etc/apt/sources.list.d/broken.list

# Run apt update to confirm fix
apt-get update
