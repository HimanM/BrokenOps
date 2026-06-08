#!/bin/bash

# Set the default target back to multi-user.target
systemctl set-default multi-user.target

# Isolate the target to bring up all normal services immediately
systemctl isolate multi-user.target
